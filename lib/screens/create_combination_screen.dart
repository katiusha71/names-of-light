import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/combination_item.dart';
import '../models/code_item.dart';
import '../providers/codes_provider.dart';
import '../widgets/combination_card.dart';
import '../widgets/hebrew_letter_span.dart';

class CreateCombinationScreen extends StatefulWidget {
  final CombinationItem? existing;

  const CreateCombinationScreen({super.key, this.existing});

  @override
  State<CreateCombinationScreen> createState() =>
      _CreateCombinationScreenState();
}

class _CreateCombinationScreenState extends State<CreateCombinationScreen> {
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  String _selectedIcon = 'auto_awesome';
  final List<int> _selectedCodeIds = [];

  bool get _isEditing => widget.existing != null;

  static const _availableIcons = [
    'auto_awesome',
    'self_improvement',
    'healing',
    'monetization_on',
    'favorite',
    'shield',
    'trending_up',
    'work',
    'family_restroom',
    'spa',
    'volunteer_activism',
    'child_friendly',
    'flight',
    'school',
    'link_off',
    'nights_stay',
    'wb_sunny',
    'bedtime',
    'gavel',
  ];

  @override
  void initState() {
    super.initState();
    _nameController.addListener(() => setState(() {}));
    if (_isEditing) {
      final e = widget.existing!;
      _nameController.text = e.name;
      _descriptionController.text = e.description;
      _selectedIcon = e.icon;
      _selectedCodeIds.addAll(e.codeIds);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _toggleCode(int codeId) {
    setState(() {
      if (_selectedCodeIds.contains(codeId)) {
        _selectedCodeIds.remove(codeId);
      } else {
        _selectedCodeIds.add(codeId);
      }
    });
  }

  Future<void> _save() async {
    final name = _nameController.text.trim();
    if (name.isEmpty || _selectedCodeIds.isEmpty) return;

    final provider = context.read<CodesProvider>();
    final description = _descriptionController.text.trim();

    if (_isEditing) {
      final updated = widget.existing!.copyWith(
        name: name,
        nameRu: name,
        description: description,
        descriptionRu: description,
        category: 'Custom',
        categoryRu: 'Пользовательские',
        codeIds: List<int>.from(_selectedCodeIds),
        icon: _selectedIcon,
      );
      await provider.updateCustomCombination(updated);
    } else {
      final combo = CombinationItem(
        id: 0, // will be assigned by provider
        name: name,
        nameRu: name,
        description: description,
        descriptionRu: description,
        category: 'Custom',
        categoryRu: 'Пользовательские',
        codeIds: List<int>.from(_selectedCodeIds),
        icon: _selectedIcon,
        isCustom: true,
      );
      await provider.addCustomCombination(combo);
    }

    if (mounted) Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CodesProvider>();
    final isRu = provider.isRussian;
    final allCodes = provider.allCodes;

    return Scaffold(
      backgroundColor: const Color(0xFF0A0A1A),
      body: Stack(
        children: [
          Center(
            child: SingleChildScrollView(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 700),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 30),
                      Center(
                        child: Text(
                          _isEditing
                              ? (isRu
                                  ? 'Редактировать комбинацию'
                                  : 'Edit Combination')
                              : (isRu
                                  ? 'Создать комбинацию'
                                  : 'Create Combination'),
                          style: TextStyle(
                            color: Colors.white.withAlpha(230),
                            fontSize: 24,
                            fontWeight: FontWeight.w300,
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),
                      // Name field
                      Text(
                        isRu ? 'НАЗВАНИЕ' : 'NAME',
                        style: TextStyle(
                          color: Colors.white.withAlpha(80),
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 1.2,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _nameController,
                        style:
                            const TextStyle(color: Colors.white, fontSize: 16),
                        decoration: InputDecoration(
                          hintText: isRu ? 'Название комбинации' : 'Combination name',
                          hintStyle:
                              TextStyle(color: Colors.white.withAlpha(60)),
                          filled: true,
                          fillColor: const Color(0xFF12122A),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide:
                                BorderSide(color: Colors.white.withAlpha(30)),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide:
                                BorderSide(color: Colors.white.withAlpha(30)),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide:
                                BorderSide(color: Colors.white.withAlpha(80)),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      // Description field
                      Text(
                        isRu ? 'ОПИСАНИЕ (необязательно)' : 'DESCRIPTION (optional)',
                        style: TextStyle(
                          color: Colors.white.withAlpha(80),
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 1.2,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _descriptionController,
                        style:
                            const TextStyle(color: Colors.white, fontSize: 14),
                        maxLines: 3,
                        decoration: InputDecoration(
                          hintText: isRu ? 'Описание...' : 'Description...',
                          hintStyle:
                              TextStyle(color: Colors.white.withAlpha(60)),
                          filled: true,
                          fillColor: const Color(0xFF12122A),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide:
                                BorderSide(color: Colors.white.withAlpha(30)),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide:
                                BorderSide(color: Colors.white.withAlpha(30)),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide:
                                BorderSide(color: Colors.white.withAlpha(80)),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      // Icon picker
                      Text(
                        isRu ? 'ИКОНКА' : 'ICON',
                        style: TextStyle(
                          color: Colors.white.withAlpha(80),
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 1.2,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: _availableIcons.map((iconName) {
                          final isSelected = _selectedIcon == iconName;
                          return GestureDetector(
                            onTap: () =>
                                setState(() => _selectedIcon = iconName),
                            child: Container(
                              width: 42,
                              height: 42,
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? Colors.white.withAlpha(20)
                                    : const Color(0xFF12122A),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: isSelected
                                      ? Colors.white.withAlpha(120)
                                      : Colors.white.withAlpha(20),
                                  width: isSelected ? 2 : 1,
                                ),
                              ),
                              child: Icon(
                                mapCombinationIcon(iconName),
                                color: isSelected
                                    ? Colors.white
                                    : Colors.white.withAlpha(100),
                                size: 20,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 24),
                      // Code selector
                      Row(
                        children: [
                          Text(
                            isRu ? 'ВЫБЕРИТЕ КОДЫ' : 'SELECT CODES',
                            style: TextStyle(
                              color: Colors.white.withAlpha(80),
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 1.2,
                            ),
                          ),
                          const SizedBox(width: 8),
                          if (_selectedCodeIds.isNotEmpty)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.white.withAlpha(15),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                '${_selectedCodeIds.length}',
                                style: TextStyle(
                                  color: Colors.white.withAlpha(150),
                                  fontSize: 11,
                                ),
                              ),
                            ),
                        ],
                      ),
                      if (_selectedCodeIds.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        _buildSelectedOrder(allCodes, isRu),
                      ],
                      const SizedBox(height: 12),
                      _buildCodeSelectorGrid(allCodes, isRu),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ),
          ),
          // Back button
          Positioned(
            top: 16,
            left: 16,
            child: SafeArea(
              child: IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: Icon(
                  Icons.arrow_back_rounded,
                  color: Colors.white.withAlpha(120),
                ),
                tooltip: isRu ? 'Назад' : 'Back',
              ),
            ),
          ),
          // Save button
          Positioned(
            top: 16,
            right: 16,
            child: SafeArea(
              child: GestureDetector(
                onTap: _nameController.text.trim().isNotEmpty &&
                        _selectedCodeIds.isNotEmpty
                    ? _save
                    : null,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  decoration: BoxDecoration(
                    color: _nameController.text.trim().isNotEmpty &&
                            _selectedCodeIds.isNotEmpty
                        ? Colors.white.withAlpha(15)
                        : Colors.white.withAlpha(5),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: _nameController.text.trim().isNotEmpty &&
                              _selectedCodeIds.isNotEmpty
                          ? Colors.white.withAlpha(80)
                          : Colors.white.withAlpha(20),
                    ),
                  ),
                  child: Text(
                    isRu ? 'Сохранить' : 'Save',
                    style: TextStyle(
                      color: _nameController.text.trim().isNotEmpty &&
                              _selectedCodeIds.isNotEmpty
                          ? Colors.white
                          : Colors.white.withAlpha(40),
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSelectedOrder(List<CodeItem> allCodes, bool isRu) {
    return SizedBox(
      height: 36,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _selectedCodeIds.length,
        separatorBuilder: (_, __) => Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Icon(Icons.arrow_forward_ios,
              size: 10, color: Colors.white.withAlpha(40)),
        ),
        itemBuilder: (context, index) {
          final codeId = _selectedCodeIds[index];
          final code = allCodes.firstWhere((c) => c.id == codeId);
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: code.color.withAlpha(20),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: code.color.withAlpha(60)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '${index + 1}.',
                  style: TextStyle(
                    color: code.color,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: 4),
                HebrewLetterRow(
                  letters: code.letters,
                  fontSize: 14,
                  color: code.color,
                  isRussian: isRu,
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildCodeSelectorGrid(List<CodeItem> allCodes, bool isRu) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final cols = (constraints.maxWidth / 90).floor().clamp(4, 8);
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: cols,
            childAspectRatio: 0.85,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
          ),
          itemCount: allCodes.length,
          itemBuilder: (context, index) {
            final code = allCodes[index];
            final orderIndex = _selectedCodeIds.indexOf(code.id);
            final isSelected = orderIndex != -1;
            return GestureDetector(
              onTap: () => _toggleCode(code.id),
              child: Container(
                decoration: BoxDecoration(
                  color: isSelected
                      ? code.color.withAlpha(25)
                      : const Color(0xFF12122A),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: isSelected
                        ? code.color.withAlpha(150)
                        : Colors.white.withAlpha(15),
                    width: isSelected ? 2 : 1,
                  ),
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        HebrewLetterRow(
                          letters: code.letters,
                          fontSize: 16,
                          color: isSelected
                              ? code.color
                              : code.color.withAlpha(120),
                          isRussian: isRu,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '#${code.id}',
                          style: TextStyle(
                            color: isSelected
                                ? Colors.white.withAlpha(150)
                                : Colors.white.withAlpha(50),
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                    if (isSelected)
                      Positioned(
                        top: 4,
                        right: 6,
                        child: Container(
                          width: 18,
                          height: 18,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: code.color,
                          ),
                          child: Center(
                            child: Text(
                              '${orderIndex + 1}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
