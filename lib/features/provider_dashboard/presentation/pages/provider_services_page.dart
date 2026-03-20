import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sweet_mobile_app/core/theme/app_colors.dart';
import 'package:sweet_mobile_app/features/provider_dashboard/presentation/providers/provider_services_notifier.dart';
import 'package:sweet_mobile_app/shared/models/category_model.dart';
import 'package:sweet_mobile_app/shared/models/service_model.dart';
import 'package:sweet_mobile_app/shared/widgets/empty_state.dart';
import 'package:sweet_mobile_app/shared/widgets/sweet_button.dart';

class ProviderServicesPage extends ConsumerWidget {
  const ProviderServicesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final servicesAsync = ref.watch(providerServicesProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        title: const Text('Mis Servicios'),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showServiceSheet(context, ref, null),
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label:
            const Text('Nuevo servicio', style: TextStyle(color: Colors.white)),
      ),
      body: servicesAsync.when(
        loading: () => const Center(
            child: CircularProgressIndicator(color: AppColors.primary)),
        error: (e, _) => EmptyState(
          icon: Icons.error_outline_rounded,
          title: 'Error al cargar servicios',
          subtitle: e.toString(),
          actionLabel: 'Reintentar',
          onAction: () => ref.read(providerServicesProvider.notifier).refresh(),
        ),
        data: (services) => services.isEmpty
            ? EmptyState(
                icon: Icons.spa_rounded,
                title: 'Sin servicios aún',
                subtitle: 'Agrega tu primer servicio para recibir solicitudes.',
                actionLabel: 'Crear servicio',
                onAction: () => _showServiceSheet(context, ref, null),
              )
            : RefreshIndicator(
                color: AppColors.primary,
                onRefresh: () =>
                    ref.read(providerServicesProvider.notifier).refresh(),
                child: ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
                  itemCount: services.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (context, i) => _ServiceCard(
                    service: services[i],
                    onEdit: () => _showServiceSheet(context, ref, services[i]),
                    onDelete: () =>
                        _confirmDelete(context, ref, services[i].id),
                  ),
                ),
              ),
      ),
    );
  }

  void _showServiceSheet(
    BuildContext context,
    WidgetRef ref,
    ServiceModel? existing,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _ServiceFormSheet(existing: existing),
    );
  }

  Future<void> _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    String serviceId,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('Eliminar servicio',
            style: TextStyle(color: AppColors.onSurface)),
        content: const Text(
          '¿Estás segura? Esta acción no se puede deshacer.',
          style: TextStyle(color: AppColors.onSurfaceVariant),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancelar')),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Eliminar',
                style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      await ref.read(providerServicesProvider.notifier).delete(serviceId);
    }
  }
}

// ── Service Card ─────────────────────────────────────────────

class _ServiceCard extends StatelessWidget {
  const _ServiceCard({
    required this.service,
    required this.onEdit,
    required this.onDelete,
  });

  final ServiceModel service;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: service.isActive
              ? AppColors.primary.withOpacity(0.3)
              : AppColors.outlineVariant,
        ),
      ),
      child: ListTile(
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.15),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(Icons.spa_rounded, color: AppColors.primary),
        ),
        title: Text(
          service.title,
          style: const TextStyle(
              color: AppColors.onSurface, fontWeight: FontWeight.w600),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (service.description != null)
              Text(
                service.description!,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                    color: AppColors.onSurfaceVariant, fontSize: 12),
              ),
            const SizedBox(height: 4),
            Row(
              children: [
                Text(
                  service.priceLabel,
                  style: const TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                      fontSize: 13),
                ),
                if (service.durationMinutes != null) ...[
                  const Text('  ·  ',
                      style: TextStyle(color: AppColors.onSurfaceVariant)),
                  Text(
                    '${service.durationMinutes} min',
                    style: const TextStyle(
                        color: AppColors.onSurfaceVariant, fontSize: 12),
                  ),
                ],
              ],
            ),
          ],
        ),
        trailing: PopupMenuButton<String>(
          color: AppColors.surface,
          icon: const Icon(Icons.more_vert_rounded,
              color: AppColors.onSurfaceVariant),
          onSelected: (v) {
            if (v == 'edit') onEdit();
            if (v == 'delete') onDelete();
          },
          itemBuilder: (_) => [
            const PopupMenuItem(
              value: 'edit',
              child: Row(children: [
                Icon(Icons.edit_rounded, size: 18, color: AppColors.secondary),
                SizedBox(width: 8),
                Text('Editar', style: TextStyle(color: AppColors.onSurface)),
              ]),
            ),
            const PopupMenuItem(
              value: 'delete',
              child: Row(children: [
                Icon(Icons.delete_rounded, size: 18, color: AppColors.error),
                SizedBox(width: 8),
                Text('Eliminar', style: TextStyle(color: AppColors.error)),
              ]),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Service Form Sheet ────────────────────────────────────────

class _ServiceFormSheet extends ConsumerStatefulWidget {
  const _ServiceFormSheet({this.existing});
  final ServiceModel? existing;

  @override
  ConsumerState<_ServiceFormSheet> createState() => _ServiceFormSheetState();
}

class _ServiceFormSheetState extends ConsumerState<_ServiceFormSheet> {
  final _formKey = GlobalKey<FormState>();
  late final _titleCtrl = TextEditingController(text: widget.existing?.title);
  late final _descCtrl =
      TextEditingController(text: widget.existing?.description);
  late final _priceCtrl = TextEditingController(
      text: widget.existing?.price.toStringAsFixed(0) ?? '');
  late final _durationCtrl = TextEditingController(
      text: widget.existing?.durationMinutes?.toString() ?? '');

  String _priceType = 'SESSION';
  String? _categoryId;

  @override
  void initState() {
    super.initState();
    if (widget.existing != null) {
      _priceType = widget.existing!.priceType;
      _categoryId = widget.existing!.category?.id;
    }
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    _priceCtrl.dispose();
    _durationCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final formState = ref.watch(serviceFormProvider);
    final categoriesAsync = ref.watch(categoriesForFormProvider);
    final isLoading = formState is ServiceFormLoading;

    ref.listen(serviceFormProvider, (_, next) {
      if (next is ServiceFormSuccess) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.existing != null
                ? 'Servicio actualizado'
                : 'Servicio creado'),
            backgroundColor: AppColors.success,
          ),
        );
        ref.read(serviceFormProvider.notifier).reset();
      }
    });

    return Padding(
      padding: EdgeInsets.fromLTRB(
          20, 20, 20, MediaQuery.viewInsetsOf(context).bottom + 20),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                widget.existing != null ? 'Editar servicio' : 'Nuevo servicio',
                style: const TextStyle(
                    color: AppColors.onSurface,
                    fontSize: 18,
                    fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),

              // Título
              _Field(
                controller: _titleCtrl,
                label: 'Título del servicio',
                validator: (v) =>
                    (v?.isEmpty ?? true) ? 'Campo requerido' : null,
              ),
              const SizedBox(height: 12),

              // Descripción
              _Field(
                controller: _descCtrl,
                label: 'Descripción',
                maxLines: 2,
              ),
              const SizedBox(height: 12),

              // Precio + Tipo
              Row(
                children: [
                  Expanded(
                    child: _Field(
                      controller: _priceCtrl,
                      label: 'Precio (\$)',
                      keyboardType: TextInputType.number,
                      validator: (v) =>
                          (v?.isEmpty ?? true) ? 'Requerido' : null,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _priceType,
                      dropdownColor: AppColors.surface,
                      decoration: _inputDecoration('Tipo de precio'),
                      style: const TextStyle(color: AppColors.onSurface),
                      items: const [
                        DropdownMenuItem(
                            value: 'SESSION', child: Text('Por sesión')),
                        DropdownMenuItem(value: 'HOUR', child: Text('Por hora')),
                        DropdownMenuItem(
                            value: 'FIXED', child: Text('Precio fijo')),
                      ],
                      onChanged: (v) => setState(() => _priceType = v!),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Duración
              _Field(
                controller: _durationCtrl,
                label: 'Duración (minutos, opcional)',
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 12),

              // Categoría
              categoriesAsync.when(
                loading: () => const LinearProgressIndicator(
                    color: AppColors.primary),
                error: (_, __) => const SizedBox(),
                data: (categories) => DropdownButtonFormField<String>(
                  value: _categoryId,
                  dropdownColor: AppColors.surface,
                  decoration: _inputDecoration('Categoría'),
                  style: const TextStyle(color: AppColors.onSurface),
                  validator: (v) =>
                      (v == null || v.isEmpty) ? 'Selecciona una categoría' : null,
                  items: categories
                      .map((c) => DropdownMenuItem(
                            value: c.id,
                            child: Text(c.name),
                          ))
                      .toList(),
                  onChanged: (v) => setState(() => _categoryId = v),
                ),
              ),
              const SizedBox(height: 24),

              if (formState is ServiceFormError)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Text(
                    formState.message,
                    style: const TextStyle(color: AppColors.error, fontSize: 12),
                  ),
                ),

              SweetButton.primary(
                label: isLoading
                    ? 'Guardando...'
                    : (widget.existing != null ? 'Guardar cambios' : 'Crear servicio'),
                onPressed: isLoading ? null : _submit,
              ),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String label) => InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: AppColors.onSurfaceVariant),
        border: const OutlineInputBorder(),
        enabledBorder: OutlineInputBorder(
          borderSide:
              BorderSide(color: AppColors.outlineVariant.withOpacity(0.5)),
        ),
      );

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_categoryId == null) return;

    await ref.read(serviceFormProvider.notifier).submit(
          existingId: widget.existing?.id,
          title: _titleCtrl.text.trim(),
          description: _descCtrl.text.trim(),
          price: double.tryParse(_priceCtrl.text) ?? 0,
          priceType: _priceType,
          categoryId: _categoryId!,
          durationMinutes: int.tryParse(_durationCtrl.text),
        );
  }
}

class _Field extends StatelessWidget {
  const _Field({
    required this.controller,
    required this.label,
    this.maxLines = 1,
    this.keyboardType,
    this.validator,
  });

  final TextEditingController controller;
  final String label;
  final int maxLines;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      validator: validator,
      style: const TextStyle(color: AppColors.onSurface),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: AppColors.onSurfaceVariant),
        border: const OutlineInputBorder(),
        enabledBorder: OutlineInputBorder(
          borderSide:
              BorderSide(color: AppColors.outlineVariant.withOpacity(0.5)),
        ),
      ),
    );
  }
}
