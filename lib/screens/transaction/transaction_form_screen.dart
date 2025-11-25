import 'dart:developer' as developer;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:horizon_finance/features/transactions/models/transactions.dart';
import 'package:horizon_finance/features/transactions/services/transaction_service.dart';
import 'package:horizon_finance/widgets/bottom_nav_menu.dart';

// Modelo para categorias
class Category {
  final int id;
  final String nome;
  final String tipo;

  Category({required this.id, required this.nome, required this.tipo});
}

class TransactionFormScreen extends ConsumerStatefulWidget {
  final TransactionType initialType;
  final Transaction? transaction;
  final bool isEditing;

  const TransactionFormScreen({
    super.key,
    required this.initialType,
    this.transaction,
    this.isEditing = false,
  });

  @override
  ConsumerState<TransactionFormScreen> createState() =>
      _TransactionFormScreenState();
}

class _TransactionFormScreenState
    extends ConsumerState<TransactionFormScreen> {
  late TransactionType _type;
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final TextEditingController _valueController = TextEditingController();
  final TextEditingController _descriptionController =
      TextEditingController();

  // Estados
  DateTime _selectedDate = DateTime.now();
  int? _selectedCategoryId;
  bool _isLoading = false;

  // Mapeamento completo das categorias
  static final List<Category> _allCategories = [
    // RECEITAS
    Category(id: 1, nome: 'Salário', tipo: 'RECEITA'),
    Category(id: 2, nome: 'Renda Extra (Freela)', tipo: 'RECEITA'),
    Category(id: 3, nome: 'Investimentos', tipo: 'RECEITA'),
    Category(id: 4, nome: 'Presentes', tipo: 'RECEITA'),
    Category(id: 5, nome: 'Outras Receitas', tipo: 'RECEITA'),

    // DESPESAS
    Category(id: 6, nome: 'Aluguel', tipo: 'DESPESA'),
    Category(id: 7, nome: 'Financiamento', tipo: 'DESPESA'),
    Category(id: 8, nome: 'Condomínio', tipo: 'DESPESA'),
    Category(id: 9, nome: 'Água', tipo: 'DESPESA'),
    Category(id: 10, nome: 'Energia Elétrica', tipo: 'DESPESA'),
    Category(id: 11, nome: 'Internet / TV / Telefone', tipo: 'DESPESA'),
    Category(id: 12, nome: 'Casa', tipo: 'DESPESA'),
    Category(id: 13, nome: 'Supermercado', tipo: 'DESPESA'),
    Category(id: 14, nome: 'Restaurantes / Delivery', tipo: 'DESPESA'),
    Category(id: 15, nome: 'Veículo', tipo: 'DESPESA'),
    Category(id: 16, nome: 'Transporte', tipo: 'DESPESA'),
    Category(id: 17, nome: 'Saúde', tipo: 'DESPESA'),
    Category(id: 18, nome: 'Cuidados Pessoais', tipo: 'DESPESA'),
    Category(id: 19, nome: 'Academia / Esportes', tipo: 'DESPESA'),
    Category(id: 20, nome: 'Lazer e Entretenimento', tipo: 'DESPESA'),
    Category(id: 21, nome: 'Compras', tipo: 'DESPESA'),
    Category(id: 22, nome: 'Assinaturas', tipo: 'DESPESA'),
    Category(id: 23, nome: 'Investimentos (Aportes)', tipo: 'DESPESA'),
    Category(id: 24, nome: 'Presentes / Doações', tipo: 'DESPESA'),
    Category(id: 25, nome: 'Educação', tipo: 'DESPESA'),
    Category(id: 26, nome: 'Outras Despesas', tipo: 'DESPESA'),
  ];

  // Filtra categorias por tipo
  List<Category> get _currentCategories {
    final tipoString =
        _type == TransactionType.receita ? 'RECEITA' : 'DESPESA';
    return _allCategories.where((cat) => cat.tipo == tipoString).toList();
  }

  @override
  void initState() {
    super.initState();
    _type = widget.initialType;

    // Se estiver editando, preenche os campos
    if (widget.isEditing && widget.transaction != null) {
      final t = widget.transaction!;
      _descriptionController.text = t.descricao;
      _selectedDate = t.data ?? DateTime.now();
      _type = t.tipo;
      _selectedCategoryId = t.categoriaId;

      // Formata o valor inicial
      final formatter =
          NumberFormat.currency(locale: 'pt_BR', symbol: '');
      _valueController.text = formatter.format(t.valor).trim();
    }
  }

  @override
  void dispose() {
    _valueController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  // Converte o valor formatado para double
  double _parseValue(String text) {
    if (text.isEmpty) return 0.0;

    String cleanValue = text
        .replaceAll('R\$', '')
        .replaceAll(' ', '')
        .replaceAll('.', '')
        .replaceAll(',', '.');

    return double.tryParse(cleanValue) ?? 0.0;
  }

  // Salva ou atualiza a transação
  Future<void> _saveTransaction() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final valor = _parseValue(_valueController.text);
    final descricao = _descriptionController.text.isEmpty
        ? (_type == TransactionType.receita ? 'Receita' : 'Despesa')
        : _descriptionController.text;

    final categoria = _allCategories.firstWhere(
      (cat) => cat.id == _selectedCategoryId,
      orElse: () =>
          Category(id: 0, nome: 'Desconhecida', tipo: ''),
    );

    developer.log(
      '''Dados do formulário:
      - Tipo: ${_type == TransactionType.receita ? "RECEITA" : "DESPESA"}
      - Valor: R\$ ${valor.toStringAsFixed(2)}
      - Descrição: $descricao
      - Categoria ID: $_selectedCategoryId (${categoria.nome})
      - Data: ${_selectedDate.toIso8601String()}
      - Fixed Transaction: false''',
      name: 'TransactionFormScreen',
    );

    if (valor <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Insira um valor maior que zero'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final transactionService = ref.read(TransactionServiceProvider);

      if (widget.isEditing && widget.transaction != null) {
        await transactionService.updateTransaction(
          id: widget.transaction!.id,
          descricao: descricao,
          tipo: _type,
          valor: valor,
          data: _selectedDate,
          categoriaId: _selectedCategoryId!,
          fixedTransaction: false,
        );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Transação atualizada com sucesso!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        await transactionService.addTransaction(
          descricao: descricao,
          tipo: _type,
          valor: valor,
          data: _selectedDate,
          categoriaId: _selectedCategoryId!,
          fixedTransaction: false,
        );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Transação registrada com sucesso!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      }

      if (mounted) Navigator.of(context).pop(true);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao salvar: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  // Deleta a transação
  Future<void> _deleteTransaction() async {
    if (widget.transaction == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar exclusão'),
        content: const Text('Tem certeza que deseja excluir esta transação?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() => _isLoading = true);

    try {
      final service = ref.read(TransactionServiceProvider);
      await service.deleteTransaction(widget.transaction!.id);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Transação excluída com sucesso!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao excluir: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: ColorScheme.light(
              primary: Theme.of(context).primaryColor,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: const Color(0xFF424242),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _selectedDate) {
      setState(() => _selectedDate = picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    final primaryBlue = Theme.of(context).primaryColor;

    final Color typeColor = _type == TransactionType.receita
        ? const Color(0xFF2E7D32)
        : const Color(0xFFE53935);

    final String title = widget.isEditing
        ? 'Editar ${_type == TransactionType.receita ? "Receita" : "Despesa"}'
        : 'Nova ${_type == TransactionType.receita ? "Receita" : "Despesa"}';

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(
          title,
          style: TextStyle(
            color: typeColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: IconThemeData(color: typeColor),
        actions: widget.isEditing ? null : [_buildTypeSwapButton(typeColor)],
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 10),
                  _buildValueField(typeColor),
                  const SizedBox(height: 20),
                  _buildCategoryDropdown(typeColor),
                  const SizedBox(height: 20),
                  _buildDescriptionField(typeColor),
                  const SizedBox(height: 20),
                  _buildDateField(typeColor),
                  const SizedBox(height: 40),
                  _buildActionButton(
                      typeColor,
                      widget.isEditing
                          ? 'Salvar Alterações'
                          : 'Registrar'),
                  if (widget.isEditing) _buildDeleteButton(),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),

          if (_isLoading)
            Container(
              color: Colors.black.withOpacity(0.3),
              child: const Center(
                child:
                    CircularProgressIndicator(color: Colors.white),
              ),
            ),
        ],
      ),
      bottomNavigationBar: BottomNavMenu(
        currentIndex: -1, 
        primaryColor: primaryBlue,
      ),
    );
  }

  // Widgets auxiliares

  Widget _buildTypeSwapButton(Color typeColor) {
    final bool isReceita = _type == TransactionType.receita;

    return TextButton.icon(
      icon: Icon(
          isReceita ? Icons.arrow_downward : Icons.arrow_upward,
          color: typeColor,
          size: 18),
      label: Text(
        isReceita ? 'Despesa' : 'Receita',
        style: TextStyle(color: typeColor, fontSize: 12),
      ),
      onPressed: () {
        setState(() {
          _type = isReceita
              ? TransactionType.despesa
              : TransactionType.receita;
          _selectedCategoryId = null;
        });
      },
    );
  }

  Widget _buildValueField(Color color) {
    return TextFormField(
      controller: _valueController,
      keyboardType:
          const TextInputType.numberWithOptions(decimal: true),
      onChanged: (value) {
        final cleanValue =
            value.replaceAll(RegExp(r'[^\d]'), '');
        if (cleanValue.isNotEmpty) {
          final number = int.parse(cleanValue);
          final formatter =
              NumberFormat.currency(locale: 'pt_BR', symbol: '');
          final formatted = formatter.format(number / 100);

          _valueController.value = TextEditingValue(
            text: formatted.trim(),
            selection: TextSelection.collapsed(
                offset: formatted.trim().length),
          );
        }
      },
      decoration: InputDecoration(
        labelText: 'Valor',
        prefixText: 'R\$ ',
        prefixStyle: TextStyle(color: color, fontSize: 18),
        border: const OutlineInputBorder(
            borderRadius:
                BorderRadius.all(Radius.circular(10))),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide:
              BorderSide(color: color, width: 2),
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Insira um valor.';
        }
        final parsed = _parseValue(value);
        if (parsed <= 0) {
          return 'Insira um valor maior que zero.';
        }
        return null;
      },
    );
  }

  Widget _buildCategoryDropdown(Color typeColor) {
    return DropdownButtonFormField<int>(
      decoration: InputDecoration(
        labelText: 'Categoria',
        prefixIcon:
            Icon(Icons.category_outlined, color: typeColor),
        border: const OutlineInputBorder(
            borderRadius:
                BorderRadius.all(Radius.circular(10))),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide:
              BorderSide(color: typeColor, width: 2),
        ),
      ),
      initialValue: _selectedCategoryId,
      hint: const Text('Selecione uma categoria'),
      items: _currentCategories.map((Category category) {
        return DropdownMenuItem<int>(
          value: category.id,
          child: Text(category.nome),
        );
      }).toList(),
      onChanged: (int? newValue) {
        setState(() {
          _selectedCategoryId = newValue;
        });
      },
      validator: (value) {
        if (value == null) return 'Selecione a categoria.';
        return null;
      },
    );
  }

  Widget _buildDescriptionField(Color color) {
    return TextFormField(
      controller: _descriptionController,
      maxLength: 100,
      decoration: InputDecoration(
        labelText: 'Descrição (Opcional)',
        prefixIcon:
            Icon(Icons.description_outlined, color: color),
        border: const OutlineInputBorder(
            borderRadius:
                BorderRadius.all(Radius.circular(10))),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide:
              BorderSide(color: color, width: 2),
        ),
      ),
    );
  }

  Widget _buildDateField(Color color) {
    final DateFormat formatter = DateFormat('dd/MM/yyyy');

    return TextFormField(
      readOnly: true,
      decoration: InputDecoration(
        labelText: 'Data',
        hintText: formatter.format(_selectedDate),
        prefixIcon:
            Icon(Icons.calendar_today, color: color),
        border: const OutlineInputBorder(
            borderRadius:
                BorderRadius.all(Radius.circular(10))),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide:
              BorderSide(color: color, width: 2),
        ),
      ),
      onTap: () => _selectDate(context),
    );
  }

  Widget _buildActionButton(Color color, String text) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _saveTransaction,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          padding:
              const EdgeInsets.symmetric(vertical: 15),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10)),
          disabledBackgroundColor:
              color.withOpacity(0.5),
        ),
        child: Text(text,
            style: const TextStyle(fontSize: 18)),
      ),
    );
  }

  Widget _buildDeleteButton() {
    return Padding(
      padding: const EdgeInsets.only(top: 20.0),
      child: TextButton(
        onPressed:
            _isLoading ? null : _deleteTransaction,
        child: const Text('Excluir Transação',
            style: TextStyle(
                color: Color(0xFFE53935),
                fontSize: 16)),
      ),
    );
  }
}
