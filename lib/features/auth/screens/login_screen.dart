import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../core/constants/app_colors.dart';

// ── Country model ───────────────────────────────────────────────
class Country {
  final String flag, name, code;
  const Country(this.flag, this.name, this.code);
}

const List<Country> kCountries = [
  Country('🇮🇳', 'India', '+91'),
  Country('🇺🇸', 'USA', '+1'),
  Country('🇬🇧', 'UK', '+44'),
  Country('🇦🇺', 'Australia', '+61'),
  Country('🇦🇪', 'UAE', '+971'),
  Country('🇧🇩', 'Bangladesh', '+880'),
  Country('🇵🇰', 'Pakistan', '+92'),
];

// ══════════════════════════════════════════════════════════════════
/// Login Screen — CartKaro Delivery Partner
///
/// Design concept: a "route line" runs down the left edge of the
/// screen — the same line a rider follows on a map. Each stage of
/// login (phone → OTP → success) is a checkpoint on that line.
/// The OTP digits themselves become lit checkpoint dots instead of
/// generic input boxes. Logic (validation/timers/navigation) is
/// unchanged from the previous version — only the visual layer is new.
/// ══════════════════════════════════════════════════════════════════
class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

enum _Step { phone, otp, success }

class _LoginScreenState extends State<LoginScreen> with TickerProviderStateMixin {
  _Step _step = _Step.phone;
  bool _loading = false;
  String _error = '';
  Country _country = kCountries[0];

  final _phoneCtrl = TextEditingController();
  final List<TextEditingController> _otpCtrl =
      List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _otpFocus = List.generate(6, (_) => FocusNode());

  // Animations
  late AnimationController _entryCtrl;
  late AnimationController _stepCtrl;

  late Animation<double> _entryFade;
  late Animation<Offset> _entrySlide;
  late Animation<double> _stepFade;
  late Animation<Offset> _stepSlide;

  Timer? _resendTimer;
  int _resendSec = 30;

  @override
  void initState() {
    super.initState();

    _entryCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 650),
    );
    _entryFade = CurvedAnimation(parent: _entryCtrl, curve: Curves.easeOut);
    _entrySlide = Tween<Offset>(
      begin: const Offset(0, 0.04),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _entryCtrl, curve: Curves.easeOutCubic));

    _stepCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 360),
    );
    _stepFade = CurvedAnimation(parent: _stepCtrl, curve: Curves.easeOut);
    _stepSlide = Tween<Offset>(
      begin: const Offset(0.05, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _stepCtrl, curve: Curves.easeOutCubic));

    _entryCtrl.forward();
    _stepCtrl.forward();
  }

  @override
  void dispose() {
    _entryCtrl.dispose();
    _stepCtrl.dispose();
    _resendTimer?.cancel();
    _phoneCtrl.dispose();
    for (final c in _otpCtrl) c.dispose();
    for (final f in _otpFocus) f.dispose();
    super.dispose();
  }

  // ── OTP logic ─────────────────────────────────────────────────
  void _onOtpChanged(String value, int index) {
    if (value.isNotEmpty && index < 5) {
      _otpFocus[index + 1].requestFocus();
    }
    setState(() {}); // refresh checkpoint-dot fill state
    final full = _otpCtrl.map((c) => c.text).join();
    if (full.length == 6) _verifyOtp();
  }

  void _onOtpKey(RawKeyEvent event, int index) {
    if (event is RawKeyDownEvent &&
        event.logicalKey == LogicalKeyboardKey.backspace &&
        _otpCtrl[index].text.isEmpty &&
        index > 0) {
      _otpFocus[index - 1].requestFocus();
      _otpCtrl[index - 1].clear();
      setState(() {});
    }
  }

  // ── Actions ───────────────────────────────────────────────────
  Future<void> _sendOtp() async {
    final ph = _phoneCtrl.text;
    if (ph.length != 10) {
      setState(() => _error = 'Enter a valid 10-digit number');
      return;
    }
    if (ph != '1111111111') {
      setState(() => _error = 'Use 1111111111 for testing');
      return;
    }
    setState(() {
      _loading = true;
      _error = '';
    });
    await Future.delayed(const Duration(milliseconds: 900));
    _transitionTo(_Step.otp);
    setState(() => _loading = false);
    _startResend();
    Future.delayed(
        const Duration(milliseconds: 120), () => _otpFocus[0].requestFocus());
  }

  Future<void> _verifyOtp() async {
    final otp = _otpCtrl.map((c) => c.text).join();
    if (otp.length < 6) {
      setState(() => _error = 'Enter all 6 digits');
      return;
    }
    if (otp != '123456') {
      setState(() => _error = 'Wrong OTP. Use 123456 for testing');
      return;
    }
    setState(() {
      _loading = true;
      _error = '';
    });
    await Future.delayed(const Duration(milliseconds: 800));
    _resendTimer?.cancel();
    _transitionTo(_Step.success);
    setState(() => _loading = false);
  }

  void _transitionTo(_Step next) {
    _stepCtrl.reverse().then((_) {
      setState(() {
        _step = next;
        _error = '';
      });
      _stepCtrl.forward();
    });
  }

  void _goBack() {
    _resendTimer?.cancel();
    for (final c in _otpCtrl) c.clear();
    _transitionTo(_Step.phone);
  }

  void _startResend() {
    _resendTimer?.cancel();
    setState(() => _resendSec = 30);
    _resendTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_resendSec <= 0) {
        _resendTimer?.cancel();
        return;
      }
      setState(() => _resendSec--);
    });
  }

  // ── Build ─────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: FadeTransition(
          opacity: _entryFade,
          child: SlideTransition(
            position: _entrySlide,
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: MediaQuery.of(context).size.height -
                      MediaQuery.of(context).padding.top -
                      MediaQuery.of(context).padding.bottom -
                      44,
                ),
                child: IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // ── Route line + checkpoint markers ──────────
                      _buildRouteLine(),
                      const SizedBox(width: 20),
                      // ── Main content ──────────────────────────────
                      Expanded(child: _buildContent()),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ── Left route-line rail with 3 checkpoints ─────────────────────
  Widget _buildRouteLine() {
    final stepIndex = _step.index; // 0,1,2
    return SizedBox(
      width: 22,
      child: Column(
        children: [
          _checkpointDot(reached: true), // start: brand/app
          Expanded(child: _routeSegment(filled: stepIndex >= 1)),
          _checkpointDot(reached: stepIndex >= 1), // phone verified
          Expanded(child: _routeSegment(filled: stepIndex >= 2)),
          _checkpointDot(reached: stepIndex >= 2), // success
        ],
      ),
    );
  }

  Widget _checkpointDot({required bool reached}) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: 14,
      height: 14,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: reached ? AppColors.primary : Colors.transparent,
        border: Border.all(
          color: reached ? AppColors.primary : AppColors.border,
          width: 1.6,
        ),
        boxShadow: reached
            ? [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.45),
                  blurRadius: 10,
                  spreadRadius: 1,
                ),
              ]
            : [],
      ),
    );
  }

  Widget _routeSegment({required bool filled}) {
    return Container(
      width: 2,
      margin: const EdgeInsets.symmetric(vertical: 2),
      decoration: BoxDecoration(
        color: filled ? AppColors.primary.withOpacity(0.55) : AppColors.border,
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }

  // ── Main content column ──────────────────────────────────────────
  Widget _buildContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildBrandRow(),
        const SizedBox(height: 28),
        Expanded(
          child: FadeTransition(
            opacity: _stepFade,
            child: SlideTransition(
              position: _stepSlide,
              child: SingleChildScrollView(
                physics: const NeverScrollableScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (_error.isNotEmpty) _buildError(),
                    if (_step == _Step.phone) _buildPhoneStep(),
                    if (_step == _Step.otp) _buildOtpStep(),
                    if (_step == _Step.success) _buildSuccessStep(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBrandRow() {
    return Row(
      children: [
        Container(
          width: 38,
          height: 38,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppColors.primary.withOpacity(0.3)),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.asset(
              "assets/logo.png",
              width: 38,
              height: 38,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Text(
                'CK',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: AppColors.primary,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Text(
          'CARTKARO',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 13,
            fontWeight: FontWeight.w800,
            letterSpacing: 2.2,
          ),
        ),
        const SizedBox(width: 8),
        Container(width: 1, height: 12, color: AppColors.border),
        const SizedBox(width: 8),
        Text(
          'RIDER LOGIN',
          style: TextStyle(
            color: AppColors.primary,
            fontSize: 11,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.6,
          ),
        ),
      ],
    );
  }

  Widget _buildError() {
    return Container(
      margin: const EdgeInsets.only(bottom: 18),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.error.withOpacity(0.10),
        borderRadius: BorderRadius.circular(10),
        border: Border(left: BorderSide(color: AppColors.error, width: 3)),
      ),
      child: Row(children: [
        Icon(LucideIcons.alertTriangle, color: AppColors.error, size: 15),
        const SizedBox(width: 9),
        Expanded(
          child: Text(
            _error,
            style: TextStyle(
              color: AppColors.error,
              fontSize: 12.5,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ]),
    );
  }

  // ── Phone step ────────────────────────────────────────────────
  Widget _buildPhoneStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        _eyebrow('CHECKPOINT 01'),
        const SizedBox(height: 8),
        Text(
          'Where do we\nsend your code?',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
            letterSpacing: -0.6,
            height: 1.14,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Enter your mobile number to start riding with CartKaro.',
          style: TextStyle(
            fontSize: 13.5,
            color: AppColors.textSecondary,
            height: 1.5,
          ),
        ),
        const SizedBox(height: 28),
        _buildPhoneField(),
        const SizedBox(height: 10),
        Row(children: [
          Icon(LucideIcons.shieldCheck, size: 13, color: AppColors.textHint),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              'Indian numbers only · we never share this',
              style: TextStyle(fontSize: 11.5, color: AppColors.textHint),
            ),
          ),
        ]),
        const SizedBox(height: 26),
        _buildPrimaryButton(label: 'SEND CODE', onTap: _sendOtp),
        const SizedBox(height: 22),
        _buildMetricsStrip(),
      ],
    );
  }

  Widget _eyebrow(String text) => Text(
        text,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: AppColors.primary,
          letterSpacing: 2.0,
        ),
      );

  Widget _buildPhoneField() {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: AppColors.primary.withOpacity(0.6), width: 2),
        ),
      ),
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          GestureDetector(
            onTap: _showCountryPicker,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(_country.flag, style: const TextStyle(fontSize: 20)),
                const SizedBox(width: 6),
                Text(
                  _country.code,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(width: 2),
                Icon(LucideIcons.chevronDown, size: 14, color: AppColors.textHint),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              controller: _phoneCtrl,
              keyboardType: TextInputType.phone,
              maxLength: 10,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
                letterSpacing: 1.2,
              ),
              cursorColor: AppColors.primary,
              decoration: InputDecoration(
                hintText: '00000 00000',
                hintStyle: TextStyle(
                  color: AppColors.textHint,
                  fontWeight: FontWeight.w400,
                ),
                isCollapsed: true,
                border: InputBorder.none,
                counterText: '',
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricsStrip() {
    return Row(
      children: [
        _metric('10K+', 'RIDERS'),
        _metricDivider(),
        _metric('₹2Cr+', 'PAID OUT'),
        _metricDivider(),
        _metric('4.9', 'APP RATING'),
      ],
    );
  }

  Widget _metric(String value, String label) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 9.5,
              fontWeight: FontWeight.w700,
              color: AppColors.textHint,
              letterSpacing: 0.8,
            ),
          ),
        ],
      ),
    );
  }

  Widget _metricDivider() => Container(
        width: 1,
        height: 26,
        color: AppColors.border,
        margin: const EdgeInsets.symmetric(horizontal: 10),
      );

  // ── OTP step ─────────────────────────────────────────────────
  Widget _buildOtpStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        _eyebrow('CHECKPOINT 02'),
        const SizedBox(height: 8),
        Text(
          'Confirm it\'s you',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
            letterSpacing: -0.6,
          ),
        ),
        const SizedBox(height: 8),
        RichText(
          text: TextSpan(
            style: TextStyle(fontSize: 13.5, color: AppColors.textSecondary, height: 1.5),
            children: [
              const TextSpan(text: 'Code sent to '),
              TextSpan(
                text: '${_country.code} ${_phoneCtrl.text}',
                style: TextStyle(fontWeight: FontWeight.w700, color: AppColors.textPrimary),
              ),
            ],
          ),
        ),
        const SizedBox(height: 30),
        _buildCheckpointOtp(),
        const SizedBox(height: 14),
        GestureDetector(
          onTap: _resendSec == 0 ? _startResend : null,
          child: Row(children: [
            Icon(
              LucideIcons.refreshCw,
              size: 13,
              color: _resendSec > 0 ? AppColors.textHint : AppColors.primary,
            ),
            const SizedBox(width: 6),
            Text(
              _resendSec > 0 ? 'Resend code in ${_resendSec}s' : 'Resend code',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: _resendSec > 0 ? AppColors.textHint : AppColors.primary,
              ),
            ),
          ]),
        ),
        const SizedBox(height: 26),
        _buildPrimaryButton(label: 'VERIFY & CONTINUE', onTap: _verifyOtp),
        const SizedBox(height: 14),
        Center(
          child: TextButton.icon(
            onPressed: _goBack,
            icon: Icon(LucideIcons.arrowLeft, size: 14, color: AppColors.textSecondary),
            label: Text(
              'Use a different number',
              style: TextStyle(
                fontSize: 12.5,
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// Signature element: 6 checkpoint dots on a single connecting line.
  /// Each filled digit lights the dot above it gold, like a rider
  /// passing waypoints on a route — replaces the generic boxed OTP.
  Widget _buildCheckpointOtp() {
    return SizedBox(
      height: 92,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // connecting line
          Positioned(
            left: 16,
            right: 16,
            top: 14,
            child: Container(height: 2, color: AppColors.border),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(6, (i) {
              final filled = _otpCtrl[i].text.isNotEmpty;
              return Column(
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 13,
                    height: 13,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: filled ? AppColors.primary : AppColors.surface,
                      border: Border.all(
                        color: filled ? AppColors.primary : AppColors.border,
                        width: 1.6,
                      ),
                      boxShadow: filled
                          ? [
                              BoxShadow(
                                color: AppColors.primary.withOpacity(0.5),
                                blurRadius: 8,
                              ),
                            ]
                          : null,
                    ),
                  ),
                  const SizedBox(height: 14),
                  SizedBox(
                    width: 34,
                    child: RawKeyboardListener(
                      focusNode: FocusNode(),
                      onKey: (e) => _onOtpKey(e, i),
                      child: TextField(
                        controller: _otpCtrl[i],
                        focusNode: _otpFocus[i],
                        keyboardType: TextInputType.number,
                        maxLength: 1,
                        textAlign: TextAlign.center,
                        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                        onChanged: (v) => _onOtpChanged(v, i),
                        cursorColor: AppColors.primary,
                        style: TextStyle(
                          fontSize: 21,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                          fontFeatures: const [FontFeature.tabularFigures()],
                        ),
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          counterText: '',
                          isCollapsed: true,
                          contentPadding: const EdgeInsets.only(bottom: 4),
                        ),
                      ),
                    ),
                  ),
                ],
              );
            }),
          ),
        ],
      ),
    );
  }

  // ── Success step ──────────────────────────────────────────────
  Widget _buildSuccessStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        _eyebrow('CHECKPOINT 03 · ARRIVED'),
        const SizedBox(height: 18),
        TweenAnimationBuilder<double>(
          tween: Tween(begin: 0, end: 1),
          duration: const Duration(milliseconds: 550),
          curve: Curves.easeOutBack,
          builder: (_, v, child) => Transform.scale(scale: v, child: child),
          child: Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.primary.withOpacity(0.12),
              border: Border.all(color: AppColors.primary, width: 1.4),
            ),
            child: Icon(LucideIcons.check, size: 28, color: AppColors.primary),
          ),
        ),
        const SizedBox(height: 22),
        Text(
          "You're verified",
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'One last step — complete your rider profile\nto start accepting deliveries.',
          style: TextStyle(fontSize: 13.5, color: AppColors.textSecondary, height: 1.5),
        ),
        const SizedBox(height: 28),
        _buildPrimaryButton(
            label: 'COMPLETE REGISTRATION',
            onTap: () => context.go(
              '/delivery-partner-registration-screen',
              extra: '${_country.code} ${_phoneCtrl.text}',
            ),
          ),
        ],
      );
    }

  // ── Shared: primary button (flat, sharp-edged, label-style) ────
  Widget _buildPrimaryButton({required String label, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: _loading ? null : onTap,
      child: Container(
        height: 52,
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(4),
        ),
        child: Center(
          child: _loading
              ? SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.4,
                    valueColor: AlwaysStoppedAnimation(AppColors.background),
                  ),
                )
              : Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      label,
                      style: TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w800,
                        color: AppColors.background,
                        letterSpacing: 1.4,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Icon(LucideIcons.arrowRight, size: 16, color: AppColors.background),
                  ],
                ),
        ),
      ),
    );
  }

  // ── Country picker bottom sheet ───────────────────────────────
  void _showCountryPicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(16),
            topRight: Radius.circular(16),
          ),
          border: Border.all(color: AppColors.border, width: 1),
        ),
        padding: const EdgeInsets.fromLTRB(0, 14, 0, 0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 32,
              height: 3,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 18),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 22),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'SELECT COUNTRY',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                    letterSpacing: 1.4,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            ...kCountries.map((c) {
              final isSel = c.code == _country.code;
              return InkWell(
                onTap: () {
                  setState(() => _country = c);
                  Navigator.pop(context);
                },
                child: Container(
                  decoration: BoxDecoration(
                    border: Border(
                      left: BorderSide(
                        color: isSel ? AppColors.primary : Colors.transparent,
                        width: 3,
                      ),
                    ),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 19, vertical: 14),
                  child: Row(
                    children: [
                      Text(c.flag, style: const TextStyle(fontSize: 22)),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Text(
                          c.name,
                          style: TextStyle(
                            fontSize: 14.5,
                            fontWeight: isSel ? FontWeight.w700 : FontWeight.w500,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                      Text(
                        c.code,
                        style: TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w700,
                          color: isSel ? AppColors.primary : AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
            SizedBox(height: MediaQuery.of(context).padding.bottom + 16),
          ],
        ),
      ),
    );
  }
}