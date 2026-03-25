import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../providers/codes_provider.dart';
import '../widgets/code_card.dart';
import '../widgets/combination_card.dart';
import 'meditation_screen.dart';
import 'combination_screen.dart';
import 'create_combination_screen.dart';
import 'tree_screen.dart';
import 'pair_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final _searchController = TextEditingController();
  final _focusNode = FocusNode();
  int _focusedIndex = 0;

  @override
  void dispose() {
    _searchController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _openMeditation(BuildContext context, codeItem, bool isRussian) {
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            MeditationScreen(item: codeItem, isRussian: isRussian),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 500),
      ),
    );
  }

  void _openCombination(BuildContext context, CodesProvider provider,
      combination) {
    final codes = provider.getCodesForCombination(combination);
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            CombinationScreen(
          combination: combination,
          codes: codes,
          isRussian: provider.isRussian,
        ),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 500),
      ),
    );
  }

  void _openCreateCombination(BuildContext context) {
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            const CreateCombinationScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 500),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<CodesProvider>(
      builder: (context, provider, _) {
        if (provider.isLoading) {
          return const Scaffold(
            backgroundColor: Color(0xFF0A0A1A),
            body: Center(
              child: CircularProgressIndicator(color: Colors.white38),
            ),
          );
        }

        final codes = provider.filteredCodes;
        final isRu = provider.isRussian;
        final section = provider.activeSection;

        return Scaffold(
          backgroundColor: const Color(0xFF0A0A1A),
          floatingActionButton: section == DashboardSection.combinations
              ? FloatingActionButton(
                  onPressed: () => _openCreateCombination(context),
                  backgroundColor: const Color(0xFF1A1A3A),
                  foregroundColor: Colors.white.withAlpha(200),
                  tooltip: isRu ? 'Создать комбинацию' : 'Create combination',
                  child: const Icon(Icons.add),
                )
              : null,
          body: KeyboardListener(
            focusNode: _focusNode,
            autofocus: true,
            onKeyEvent: (event) {
              if (event is KeyDownEvent &&
                  section == DashboardSection.codes) {
                _handleKey(event.logicalKey, codes.length);
                if (event.logicalKey == LogicalKeyboardKey.enter &&
                    codes.isNotEmpty) {
                  _openMeditation(context, codes[_focusedIndex], isRu);
                }
              }
            },
            child: LayoutBuilder(
              builder: (context, constraints) {
                final isDesktop = constraints.maxWidth > 900;
                if (isDesktop) {
                  return Row(
                    children: [
                      _buildSidebar(provider),
                      Expanded(child: _buildContent(provider, constraints, isDesktop)),
                    ],
                  );
                }
                return Column(
                  children: [
                    _buildMobileHeader(provider),
                    Expanded(child: _buildContent(provider, constraints, isDesktop)),
                  ],
                );
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildContent(CodesProvider provider, BoxConstraints constraints, bool isDesktop) {
    final section = provider.activeSection;

    switch (section) {
      case DashboardSection.codes:
        final codes = provider.filteredCodes;
        final gridWidth = isDesktop ? constraints.maxWidth - 220 : constraints.maxWidth;
        final cols = isDesktop
            ? (gridWidth / 120).floor().clamp(4, 9)
            : (constraints.maxWidth > 600 ? 4 : 3);
        return _buildGrid(codes, cols, provider);

      case DashboardSection.combinations:
        final gridWidth = isDesktop ? constraints.maxWidth - 220 : constraints.maxWidth;
        final cols = isDesktop
            ? ((gridWidth / 120).floor() * 0.6).floor().clamp(2, 5)
            : (constraints.maxWidth > 600 ? 4 : 3);
        final comboCols = isDesktop ? cols : (cols * 0.7).floor().clamp(2, 3);
        return _buildCombinationGrid(
            provider.filteredCombinations, comboCols, provider);

      case DashboardSection.tree:
        return const TreeScreen();

      case DashboardSection.pair:
        return const PairScreen();

      case DashboardSection.archetype:
        return const TreeScreen(); // Profile merged into Tree
    }
  }

  void _handleKey(LogicalKeyboardKey key, int totalItems) {
    if (totalItems == 0) return;
    setState(() {
      if (key == LogicalKeyboardKey.arrowRight) {
        _focusedIndex = (_focusedIndex + 1) % totalItems;
      } else if (key == LogicalKeyboardKey.arrowLeft) {
        _focusedIndex = (_focusedIndex - 1 + totalItems) % totalItems;
      } else if (key == LogicalKeyboardKey.arrowDown) {
        _focusedIndex = (_focusedIndex + 9).clamp(0, totalItems - 1);
      } else if (key == LogicalKeyboardKey.arrowUp) {
        _focusedIndex = (_focusedIndex - 9).clamp(0, totalItems - 1);
      }
    });
  }

  Widget _buildTabToggle(CodesProvider provider) {
    final isRu = provider.isRussian;
    final section = provider.activeSection;

    final tabs = [
      (DashboardSection.codes, isRu ? 'Коды' : 'Codes'),
      (DashboardSection.combinations, isRu ? 'Комбо' : 'Combos'),
      (DashboardSection.tree, isRu ? 'Древо' : 'Tree'),
      (DashboardSection.pair, isRu ? 'Пара' : 'Pair'),
    ];

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A3A),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.white.withAlpha(20)),
      ),
      child: Row(
        children: tabs.map((tab) {
          final isActive = section == tab.$1;
          return Expanded(
            child: GestureDetector(
              onTap: () {
                provider.setActiveSection(tab.$1);
                _searchController.clear();
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: isActive
                      ? Colors.white.withAlpha(15)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(9),
                ),
                child: Text(
                  tab.$2,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: isActive ? Colors.white : Colors.white.withAlpha(80),
                    fontSize: 11,
                    fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildLanguageToggle(CodesProvider provider) {
    return GestureDetector(
      onTap: provider.toggleLanguage,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A3A),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.white.withAlpha(30)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'EN',
              style: TextStyle(
                color: provider.isRussian
                    ? Colors.white.withAlpha(80)
                    : Colors.white,
                fontSize: 12,
                fontWeight:
                    provider.isRussian ? FontWeight.normal : FontWeight.bold,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6),
              child: Text(
                '/',
                style: TextStyle(color: Colors.white.withAlpha(60), fontSize: 12),
              ),
            ),
            Text(
              'RU',
              style: TextStyle(
                color: provider.isRussian
                    ? Colors.white
                    : Colors.white.withAlpha(80),
                fontSize: 12,
                fontWeight:
                    provider.isRussian ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSidebar(CodesProvider provider) {
    final isRu = provider.isRussian;
    final section = provider.activeSection;
    final showSearch = section == DashboardSection.codes ||
        section == DashboardSection.combinations;
    final showCategories = showSearch;

    return Container(
      width: 220,
      color: const Color(0xFF0E0E22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 40),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    isRu ? '72 Имени' : '72 Names',
                    style: TextStyle(
                      color: Colors.white.withAlpha(220),
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                _buildLanguageToggle(provider),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              isRu ? 'Света' : 'of Light',
              style: TextStyle(
                color: Colors.white.withAlpha(120),
                fontSize: 16,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: _buildTabToggle(provider),
          ),
          if (showSearch) ...[
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: TextField(
                controller: _searchController,
                onChanged: provider.setSearchQuery,
                style: const TextStyle(color: Colors.white, fontSize: 14),
                decoration: InputDecoration(
                  hintText: isRu ? 'Поиск...' : 'Search...',
                  hintStyle: TextStyle(color: Colors.white.withAlpha(80)),
                  prefixIcon:
                      Icon(Icons.search, color: Colors.white.withAlpha(80), size: 18),
                  filled: true,
                  fillColor: const Color(0xFF1A1A3A),
                  contentPadding: const EdgeInsets.symmetric(vertical: 10),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
          ],
          if (showCategories) ...[
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                isRu ? 'КАТЕГОРИИ' : 'CATEGORIES',
                style: TextStyle(
                  color: Colors.white.withAlpha(80),
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.2,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: provider.categories
                    .map((cat) => _buildCategoryTile(cat, provider))
                    .toList(),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                section == DashboardSection.combinations
                    ? (isRu
                        ? '${provider.filteredCombinations.length} из ${provider.combinations.length}'
                        : '${provider.filteredCombinations.length} of ${provider.combinations.length}')
                    : (isRu
                        ? '${provider.filteredCodes.length} из ${provider.allCodes.length}'
                        : '${provider.filteredCodes.length} of ${provider.allCodes.length}'),
                style: TextStyle(color: Colors.white.withAlpha(60), fontSize: 12),
              ),
            ),
          ],
          if (section == DashboardSection.tree) ...[
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                isRu ? 'СЕФИРОТ' : 'SEPHIROT',
                style: TextStyle(
                  color: Colors.white.withAlpha(80),
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.2,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: provider.visibleSephirot.map((s) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 4),
                    child: Row(
                      children: [
                        Container(
                          width: 10,
                          height: 10,
                          decoration: BoxDecoration(
                            color: s.color,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            '${s.nameHebrew}  ${s.getName(isRu)}',
                            style: TextStyle(
                              color: Colors.white.withAlpha(180),
                              fontSize: 13,
                            ),
                          ),
                        ),
                        Text(
                          '${provider.getSephiraWeight(s.id).round()}%',
                          style: TextStyle(
                            color: s.color.withAlpha(180),
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
          if (section == DashboardSection.pair) ...[
            const SizedBox(height: 20),
            const Spacer(),
          ],
          if (section == DashboardSection.archetype) ...[
            const SizedBox(height: 20),
            const Spacer(),
          ],
        ],
      ),
    );
  }

  Widget _buildCategoryTile(String category, CodesProvider provider) {
    final isSelected = provider.selectedCategory == category;
    return InkWell(
      onTap: () => provider.setCategory(category),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        color: isSelected ? Colors.white.withAlpha(15) : Colors.transparent,
        child: Text(
          category,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.white.withAlpha(150),
            fontSize: 14,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildMobileHeader(CodesProvider provider) {
    final isRu = provider.isRussian;
    final section = provider.activeSection;
    final showSearch = section == DashboardSection.codes ||
        section == DashboardSection.combinations;

    return SafeArea(
      bottom: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  isRu ? '72 Имени Света' : '72 Names of Light',
                  style: TextStyle(
                    color: Colors.white.withAlpha(220),
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                _buildLanguageToggle(provider),
              ],
            ),
            const SizedBox(height: 10),
            _buildTabToggle(provider),
            if (showSearch) ...[
              const SizedBox(height: 10),
              TextField(
                controller: _searchController,
                onChanged: provider.setSearchQuery,
                style: const TextStyle(color: Colors.white, fontSize: 14),
                decoration: InputDecoration(
                  hintText: isRu ? 'Поиск имён, значений...' : 'Search names, meanings...',
                  hintStyle: TextStyle(color: Colors.white.withAlpha(80)),
                  prefixIcon:
                      Icon(Icons.search, color: Colors.white.withAlpha(80), size: 18),
                  filled: true,
                  fillColor: const Color(0xFF1A1A3A),
                  contentPadding: const EdgeInsets.symmetric(vertical: 10),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                height: 34,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: provider.categories.map((cat) {
                    final isSelected = provider.selectedCategory == cat;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: FilterChip(
                        label: Text(cat, style: const TextStyle(fontSize: 12)),
                        selected: isSelected,
                        onSelected: (_) => provider.setCategory(cat),
                        backgroundColor: const Color(0xFF1A1A3A),
                        selectedColor: Colors.white.withAlpha(30),
                        labelStyle: TextStyle(
                          color: isSelected ? Colors.white : Colors.white.withAlpha(150),
                        ),
                        side: BorderSide(color: Colors.white.withAlpha(30)),
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildGrid(
    List codes,
    int crossAxisCount,
    CodesProvider provider,
  ) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        childAspectRatio: 0.9,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: codes.length,
      itemBuilder: (context, index) {
        final item = codes[index];
        return CodeCard(
          item: item,
          isFavorite: provider.isFavorite(item.id),
          isRussian: provider.isRussian,
          onTap: () => _openMeditation(context, item, provider.isRussian),
          onFavoriteToggle: () => provider.toggleFavorite(item.id),
        );
      },
    );
  }


  Widget _buildCombinationGrid(
    List combinations,
    int crossAxisCount,
    CodesProvider provider,
  ) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        childAspectRatio: 0.85,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: combinations.length,
      itemBuilder: (context, index) {
        final combo = combinations[index];
        final codes = provider.getCodesForCombination(combo);
        return CombinationCard(
          combination: combo,
          codes: codes,
          isRussian: provider.isRussian,
          onTap: () => _openCombination(context, provider, combo),
        );
      },
    );
  }
}
