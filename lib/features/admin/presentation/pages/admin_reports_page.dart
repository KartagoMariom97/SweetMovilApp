import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sweet_mobile_app/core/theme/app_colors.dart';
import 'package:sweet_mobile_app/features/admin/data/models/trust_report_model.dart';
import 'package:sweet_mobile_app/features/admin/presentation/providers/admin_reports_notifier.dart';
import 'package:sweet_mobile_app/shared/widgets/empty_state.dart';

class AdminReportsPage extends ConsumerWidget {
  const AdminReportsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reportsAsync = ref.watch(adminReportsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        title: const Text('Trust Reports'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () => ref.read(adminReportsProvider.notifier).refresh(),
          ),
        ],
      ),
      body: reportsAsync.when(
        loading: () => const Center(
            child: CircularProgressIndicator(color: AppColors.primary)),
        error: (e, _) => EmptyState(
          icon: Icons.error_outline_rounded,
          title: 'Error al cargar',
          subtitle: e.toString(),
          actionLabel: 'Reintentar',
          onAction: () => ref.read(adminReportsProvider.notifier).refresh(),
        ),
        data: (reports) => reports.isEmpty
            ? const EmptyState(
                icon: Icons.verified_rounded,
                title: 'Sin reportes',
                subtitle: 'No hay reportes de confianza registrados.',
              )
            : RefreshIndicator(
                color: AppColors.primary,
                onRefresh: () =>
                    ref.read(adminReportsProvider.notifier).refresh(),
                child: ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: reports.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (_, i) => _ReportCard(report: reports[i]),
                ),
              ),
      ),
    );
  }
}

// ── Report Card ───────────────────────────────────────────────

class _ReportCard extends ConsumerWidget {
  const _ReportCard({required this.report});
  final TrustReportModel report;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statusColor = switch (report.status) {
      'PENDING' => AppColors.warning,
      'REVIEWED' => AppColors.success,
      'DISMISSED' => AppColors.onSurfaceVariant,
      _ => AppColors.onSurfaceVariant,
    };

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: report.isPending
              ? AppColors.warning.withOpacity(0.5)
              : AppColors.outlineVariant,
        ),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header ─────────────────────────────────────────
          Row(
            children: [
              const Icon(Icons.flag_rounded, color: AppColors.error, size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Reporte de confianza',
                  style: const TextStyle(
                      color: AppColors.onSurface,
                      fontWeight: FontWeight.bold),
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  report.status,
                  style: TextStyle(
                      color: statusColor,
                      fontSize: 10,
                      fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // ── Info ────────────────────────────────────────────
          _InfoRow(
              label: 'Reportado por',
              value: report.reporterEmail ?? report.reporterId),
          _InfoRow(
              label: 'Reportado',
              value: report.reportedEmail ?? report.reportedId),
          _InfoRow(label: 'Motivo', value: report.reason),
          _InfoRow(
              label: 'Fecha',
              value: _formatDate(report.createdAt)),

          if (report.adminNote != null && report.adminNote!.isNotEmpty)
            _InfoRow(label: 'Nota admin', value: report.adminNote!),

          // ── Acciones (solo si PENDING) ──────────────────────
          if (report.isPending) ...[
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _showActionDialog(
                        context, ref, 'DISMISSED'),
                    icon: const Icon(Icons.close_rounded, size: 14),
                    label: const Text('Desestimar'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.onSurfaceVariant,
                      side: const BorderSide(
                          color: AppColors.outlineVariant),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _showActionDialog(
                        context, ref, 'REVIEWED'),
                    icon: const Icon(Icons.check_rounded, size: 14),
                    label: const Text('Resolver'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.success,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _showActionDialog(
    BuildContext context,
    WidgetRef ref,
    String action,
  ) async {
    final noteCtrl = TextEditingController();
    final isResolve = action == 'REVIEWED';

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: Text(
          isResolve ? 'Resolver reporte' : 'Desestimar reporte',
          style: const TextStyle(color: AppColors.onSurface),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              isResolve
                  ? 'Marca este reporte como revisado y resuelto.'
                  : 'Marca este reporte como desestimado.',
              style: const TextStyle(color: AppColors.onSurfaceVariant),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: noteCtrl,
              maxLines: 2,
              style: const TextStyle(color: AppColors.onSurface),
              decoration: const InputDecoration(
                labelText: 'Nota interna (opcional)',
                labelStyle: TextStyle(color: AppColors.onSurfaceVariant),
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancelar')),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              isResolve ? 'Resolver' : 'Desestimar',
              style: TextStyle(
                  color: isResolve ? AppColors.success : AppColors.error),
            ),
          ),
        ],
      ),
    );

    if (confirmed != true || !context.mounted) return;

    bool ok;
    if (isResolve) {
      ok = await ref.read(adminReportsProvider.notifier).resolve(
            report.id,
            adminNote: noteCtrl.text.trim(),
          );
    } else {
      ok = await ref.read(adminReportsProvider.notifier).dismiss(
            report.id,
            adminNote: noteCtrl.text.trim(),
          );
    }

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(ok ? 'Reporte actualizado' : 'Error al actualizar'),
        backgroundColor: ok ? AppColors.success : AppColors.error,
      ));
    }
  }

  String _formatDate(DateTime dt) =>
      '${dt.day.toString().padLeft(2, '0')}/'
      '${dt.month.toString().padLeft(2, '0')}/'
      '${dt.year}';
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: RichText(
        text: TextSpan(
          style: const TextStyle(fontSize: 12),
          children: [
            TextSpan(
              text: '$label: ',
              style: const TextStyle(
                  color: AppColors.onSurfaceVariant,
                  fontWeight: FontWeight.w500),
            ),
            TextSpan(
              text: value,
              style: const TextStyle(color: AppColors.onSurface),
            ),
          ],
        ),
      ),
    );
  }
}
