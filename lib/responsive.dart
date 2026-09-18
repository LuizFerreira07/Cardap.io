import 'package:flutter/material.dart';

/// Breakpoints usados em todo o app.
class Breakpoints {
  Breakpoints._();
  static const double mobile = 600;
  static const double tablet = 1024;
}

enum ScreenSize { mobile, tablet, desktop }

ScreenSize screenSizeOf(BuildContext context) {
  final width = MediaQuery.of(context).size.width;
  if (width >= Breakpoints.tablet) return ScreenSize.desktop;
  if (width >= Breakpoints.mobile) return ScreenSize.tablet;
  return ScreenSize.mobile;
}

/// Envolve o conteúdo de uma tela "estilo app de celular" (pagamento,
/// carrinho, detalhe de produto, boas-vindas, feedback...).
/// No mobile ocupa a largura toda; em telas largas, é centralizado
/// dentro de um "cartão" com largura máxima, simulando o app num
/// container central e aproveitando o espaço extra com um fundo.
class ResponsivePhoneShell extends StatelessWidget {
  const ResponsivePhoneShell({
    super.key,
    required this.child,
    this.maxWidth = 480,
    this.backgroundColor,
  });

  final Widget child;
  final double maxWidth;
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    final size = screenSizeOf(context);
    if (size == ScreenSize.mobile) {
      return child;
    }
    return Container(
      color: backgroundColor ?? const Color(0xFFEDE2D0),
      width: double.infinity,
      child: Center(
        child: Container(
          width: maxWidth,
          margin: const EdgeInsets.symmetric(vertical: 32),
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.15),
                blurRadius: 40,
                offset: const Offset(0, 20),
              ),
            ],
          ),
          child: child,
        ),
      ),
    );
  }
}

/// Envolve o conteúdo de uma tela "estilo dashboard" (delivery,
/// KDS, painel do garçom) — no desktop usa uma largura maior e
/// permite grades com mais colunas.
class ResponsiveDashboardShell extends StatelessWidget {
  const ResponsiveDashboardShell({
    super.key,
    required this.child,
    this.maxWidth = 1100,
  });

  final Widget child;
  final double maxWidth;

  @override
  Widget build(BuildContext context) {
    final size = screenSizeOf(context);
    if (size == ScreenSize.mobile) {
      return child;
    }
    return Container(
      color: const Color(0xFFEDE2D0),
      width: double.infinity,
      child: Center(
        child: Container(
          width: maxWidth,
          margin: const EdgeInsets.symmetric(vertical: 32),
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            color: const Color(0xFFFDF6EC),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.12),
                blurRadius: 40,
                offset: const Offset(0, 20),
              ),
            ],
          ),
          child: child,
        ),
      ),
    );
  }
}

/// Retorna o número de colunas de uma grade de acordo com a largura
/// disponível — usado no cardápio, mapa de mesas, cards de pedido etc.
int gridColumnsFor(double width, {int mobile = 1, int tablet = 2, int desktop = 3}) {
  if (width >= Breakpoints.tablet) return desktop;
  if (width >= Breakpoints.mobile) return tablet;
  return mobile;
}