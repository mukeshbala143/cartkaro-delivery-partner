import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:go_router/go_router.dart';

// ─── AppColors (inline, matches your existing app_colors.dart) ───────────────
// Replace with: import '../../../core/constants/app_colors.dart';

class _C {
  static const background    = Color(0xFF000000);
  static const surface       = Color(0xFF121212);
  static const surfaceVar    = Color(0xFF1E1E1E);
  static const card          = Color(0xFF1A1A1A);
  static const primary       = Color(0xFFD4AF37);
  static const primaryDark   = Color(0xFFB8932E);
  static const primaryLight  = Color(0xFFE9D08E);
  static const textPrimary   = Color(0xFFFFFFFF);
  static const textSecondary = Color(0xFFB3B3B3);
  static const textHint      = Color(0xFF6E6E6E);
  static const success       = Color(0xFF2ECC71);
  static const error         = Color(0xFFE74C3C);
  static const warning       = Color(0xFFF39C12);
  static const border        = Color(0xFF2A2A2A);
  static const divider       = Color(0xFF272727);

  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [Color(0xFFD4AF37), Color(0xFFF1D58A)],
  );
}

// ─── Main Screen ─────────────────────────────────────────────────────────────

class DeliveryPartnerRegistrationScreen extends StatefulWidget {
  final String mobileNumber;
  const DeliveryPartnerRegistrationScreen({
    super.key,
    required this.mobileNumber,
  });

  @override
  State<DeliveryPartnerRegistrationScreen> createState() =>
      _DeliveryPartnerRegistrationScreenState();
}

class _DeliveryPartnerRegistrationScreenState
    extends State<DeliveryPartnerRegistrationScreen>
    with TickerProviderStateMixin {
  int _currentStep = 0;
  final PageController _pageController = PageController();
  late AnimationController _animController;
  late Animation<double> _fadeAnim;

  // ── Step 1 ──
  final _s1Form = GlobalKey<FormState>();
  File? _profilePhoto;
  final _nameCtrl    = TextEditingController();
  final _altMobCtrl  = TextEditingController();
  final _emailCtrl   = TextEditingController();
  final _dobCtrl     = TextEditingController();
  DateTime? _dob;
  String? _gender;
  final _pinCtrl     = TextEditingController();
  final _pinConfCtrl = TextEditingController();
  bool _pinVisible   = false;
  bool _pinConfVisible = false;

  // ── Step 2 ──
  final _s2Form = GlobalKey<FormState>();
  final _currAddrCtrl  = TextEditingController();
  final _latCtrl       = TextEditingController();
  final _lngCtrl       = TextEditingController();
  final _permAddrCtrl  = TextEditingController();
  final _cityCtrl      = TextEditingController();
  final _stateCtrl     = TextEditingController();
  final _pincodeCtrl   = TextEditingController();
  bool _locationLoading = false;

  // ── Step 3 ──
  final _s3Form = GlobalKey<FormState>();
  String? _vehicleType;
  String? _eBikeType;
  final _vehNumCtrl    = TextEditingController();
  final _bikeBrandCtrl = TextEditingController();
  final _bikeModelCtrl = TextEditingController();
  final _batteryCtrl   = TextEditingController();
  final _dlNumCtrl     = TextEditingController();
  File? _vehiclePhoto;
  File? _rcPhoto;
  File? _dlFront;
  File? _dlBack;

  // ── Step 4 ──
  final _s4Form = GlobalKey<FormState>();
  final _aadhaarCtrl = TextEditingController();
  File? _aadhaarFront;
  File? _aadhaarBack;
  final _panCtrl = TextEditingController();
  File? _panPhoto;
  File? _selfie;

  // ── Step 5 ──
  final _s5Form = GlobalKey<FormState>();
  final _accHolderCtrl  = TextEditingController();
  final _accNumCtrl     = TextEditingController();
  final _accConfCtrl    = TextEditingController();
  String? _bankName;
  final _ifscCtrl   = TextEditingController();
  final _branchCtrl = TextEditingController();
  final _upiCtrl    = TextEditingController();

  // ── Step 6 ──
  final _s6Form = GlobalKey<FormState>();
  final _emergNameCtrl = TextEditingController();
  String? _relation;
  final _emergMobCtrl  = TextEditingController();

  // ── Step 7 ──
  final _s7Form = GlobalKey<FormState>();
  String? _workType; // 'Full Time' | 'Part Time'
  String? _shift;    // 'Morning' | 'Afternoon'

  // ── Step 8 ──
  bool _agreementAccepted = false;

  final List<String> _stepTitles = [
    'Personal Details',
    'Address Details',
    'Vehicle Details',
    'Document Verification',
    'Bank Details',
    'Emergency Details',
    'Work Preference',
    'Agreement',
    'Submitted',
  ];

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _fadeAnim = CurvedAnimation(parent: _animController, curve: Curves.easeIn);
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    _pageController.dispose();
    for (final c in [
      _nameCtrl, _altMobCtrl, _emailCtrl, _dobCtrl, _pinCtrl, _pinConfCtrl,
      _currAddrCtrl, _latCtrl, _lngCtrl, _permAddrCtrl, _cityCtrl, _stateCtrl,
      _pincodeCtrl, _vehNumCtrl, _bikeBrandCtrl, _bikeModelCtrl, _batteryCtrl,
      _dlNumCtrl, _aadhaarCtrl, _panCtrl, _accHolderCtrl, _accNumCtrl,
      _accConfCtrl, _ifscCtrl, _branchCtrl, _upiCtrl, _emergNameCtrl, _emergMobCtrl,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  // ─── Navigation ─────────────────────────────────────────────────────────────

  void _nextStep() {
    bool valid = false;
    switch (_currentStep) {
      case 0: valid = _validateStep1(); break;
      case 1: valid = _s2Form.currentState?.validate() ?? false; break;
      case 2: valid = _validateStep3(); break;
      case 3: valid = _validateStep4(); break;
      case 4: valid = _s5Form.currentState?.validate() ?? false; break;
      case 5: valid = _s6Form.currentState?.validate() ?? false; break;
      case 6: valid = _validateStep7(); break;
      case 7: valid = _validateStep8(); break;
      default: valid = true;
    }
    if (!valid) return;
    if (_currentStep < 8) {
      setState(() => _currentStep++);
      _animController.reset();
      _animController.forward();
      _pageController.animateToPage(
        _currentStep,
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
      );
    }
  }

  void _prevStep() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
      _animController.reset();
      _animController.forward();
      _pageController.animateToPage(
        _currentStep,
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
      );
    }
  }

  // ─── Validators ──────────────────────────────────────────────────────────────

  bool _validateStep1() {
    if (_profilePhoto == null) {
      _snack('Please add a profile photo'); return false;
    }
    if (!(_s1Form.currentState?.validate() ?? false)) return false;
    if (_pinCtrl.text != _pinConfCtrl.text) {
      _snack('PINs do not match'); return false;
    }
    return true;
  }

  bool _validateStep3() {
    if (_vehicleType == null) { _snack('Select vehicle type'); return false; }
    if (_vehicleType == 'Electric Bike' && _eBikeType == null) {
      _snack('Select electric bike type'); return false;
    }
    if (!(_s3Form.currentState?.validate() ?? false)) return false;
    final needsPhoto = _vehicleType != 'Bicycle' &&
        !(_vehicleType == 'Electric Bike' && _eBikeType == 'Low Speed');
    if (needsPhoto && _vehiclePhoto == null) {
      _snack('Upload vehicle photo'); return false;
    }
    if (_vehicleType == 'Bicycle' && _vehiclePhoto == null) {
      _snack('Upload bicycle photo'); return false;
    }
    final needsDocs = (_vehicleType == 'Bike' || _vehicleType == 'Scooty') ||
        (_vehicleType == 'Electric Bike' && _eBikeType == 'High Speed');
    if (needsDocs) {
      if (_rcPhoto == null) { _snack('Upload RC document'); return false; }
      if (_dlFront == null) { _snack('Upload license front'); return false; }
      if (_dlBack == null)  { _snack('Upload license back');  return false; }
    }
    return true;
  }

  bool _validateStep4() {
    if (!(_s4Form.currentState?.validate() ?? false)) return false;
    if (_aadhaarFront == null) { _snack('Upload Aadhaar front'); return false; }
    if (_aadhaarBack == null)  { _snack('Upload Aadhaar back');  return false; }
    if (_panPhoto == null)     { _snack('Upload PAN card image'); return false; }
    if (_selfie == null)       { _snack('Capture selfie');        return false; }
    return true;
  }

  bool _validateStep7() {
    if (_workType == null) { _snack('Select work type'); return false; }
    if (_workType == 'Part Time' && _shift == null) {
      _snack('Select a shift'); return false;
    }
    return true;
  }

  bool _validateStep8() {
    if (!_agreementAccepted) {
      _snack('Please accept the agreement to continue'); return false;
    }
    return true;
  }

  void _snack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg, style: const TextStyle(color: _C.background)),
      backgroundColor: _C.primary,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    ));
  }

  // ─── Image Picker ────────────────────────────────────────────────────────────

  void _showPhotoPicker(void Function(File) onPicked, {bool selfieOnly = false}) {
    showModalBottomSheet(
      context: context,
      backgroundColor: _C.surfaceVar,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Upload Photo',
                  style: TextStyle(color: _C.textPrimary, fontSize: 18, fontWeight: FontWeight.w600)),
              const SizedBox(height: 20),
              _bsOption(Icons.camera_alt_rounded, 'Camera', () async {
                Navigator.pop(context);
                final p = await ImagePicker().pickImage(source: ImageSource.camera, imageQuality: 85);
                if (p != null) onPicked(File(p.path));
              }),
              if (!selfieOnly) ...[
                const SizedBox(height: 12),
                _bsOption(Icons.photo_library_rounded, 'Gallery / File', () async {
                  Navigator.pop(context);
                  final p = await ImagePicker().pickImage(source: ImageSource.gallery, imageQuality: 85);
                  if (p != null) onPicked(File(p.path));
                }),
              ],
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  Widget _bsOption(IconData icon, String label, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
        decoration: BoxDecoration(
          color: _C.card,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: _C.border),
        ),
        child: Row(children: [
          Container(
            width: 38, height: 38,
            decoration: const BoxDecoration(gradient: _C.primaryGradient, shape: BoxShape.circle),
            child: Icon(icon, color: _C.background, size: 18),
          ),
          const SizedBox(width: 16),
          Text(label, style: const TextStyle(color: _C.textPrimary, fontSize: 15, fontWeight: FontWeight.w500)),
          const Spacer(),
          const Icon(Icons.chevron_right_rounded, color: _C.textHint, size: 20),
        ]),
      ),
    );
  }

  // ─── Location ────────────────────────────────────────────────────────────────

  Future<void> _fetchLocation() async {
    setState(() => _locationLoading = true);
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        _snack('Please enable location services');
        await Geolocator.openLocationSettings();
        setState(() => _locationLoading = false);
        return;
      }
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          _snack('Location permission denied');
          setState(() => _locationLoading = false);
          return;
        }
      }
      if (permission == LocationPermission.deniedForever) {
        _snack('Location permission permanently denied. Enable from settings.');
        await Geolocator.openAppSettings();
        setState(() => _locationLoading = false);
        return;
      }
      final pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      final placemarks = await placemarkFromCoordinates(pos.latitude, pos.longitude);
      final p = placemarks.first;
      setState(() {
        _latCtrl.text  = pos.latitude.toStringAsFixed(6);
        _lngCtrl.text  = pos.longitude.toStringAsFixed(6);
        _currAddrCtrl.text =
            '${p.street ?? ''}, ${p.subLocality ?? ''}, ${p.locality ?? ''}, '
            '${p.administrativeArea ?? ''} - ${p.postalCode ?? ''}'.trim();
        _cityCtrl.text   = p.locality ?? '';
        _stateCtrl.text  = p.administrativeArea ?? '';
        _pincodeCtrl.text = p.postalCode ?? '';
      });
    } catch (e) {
      _snack('Could not fetch location. Try again.');
    }
    setState(() => _locationLoading = false);
  }

  // ─── Build ───────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _C.background,
      body: Column(children: [
        _buildHeader(),
        if (_currentStep < 8) _buildStepProgress(),
        Expanded(
          child: PageView(
            controller: _pageController,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              _buildStep1(),
              _buildStep2(),
              _buildStep3(),
              _buildStep4(),
              _buildStep5(),
              _buildStep6(),
              _buildStep7(),
              _buildStep8(),
              _buildStep9(),
            ],
          ),
        ),
        if (_currentStep < 8) _buildNavButtons(),
      ]),
    );
  }

  // ─── Header ──────────────────────────────────────────────────────────────────

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 12,
        left: 16, right: 16, bottom: 12,
      ),
      decoration: BoxDecoration(
        color: _C.surface,
        border: Border(bottom: BorderSide(color: _C.border)),
      ),
      child: Row(children: [
        if (_currentStep > 0 && _currentStep < 8)
          GestureDetector(
            onTap: _prevStep,
            child: Container(
              width: 36, height: 36,
              decoration: BoxDecoration(
                color: _C.surfaceVar,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: _C.border),
              ),
              child: const Icon(Icons.arrow_back_ios_new_rounded, color: _C.textPrimary, size: 16),
            ),
          )
        else
          const SizedBox(width: 36),
        const SizedBox(width: 12),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            ShaderMask(
              shaderCallback: (b) => _C.primaryGradient.createShader(b),
              child: Text(
                _currentStep < 8 ? _stepTitles[_currentStep] : 'Registration Complete',
                style: const TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w700),
              ),
            ),
            if (_currentStep < 8)
              Text(
                'Step ${_currentStep + 1} of 8',
                style: const TextStyle(color: _C.textHint, fontSize: 12),
              ),
          ]),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            gradient: _currentStep < 8 ? _C.primaryGradient : null,
            color: _currentStep == 8 ? _C.success.withOpacity(0.15) : null,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            _currentStep < 8 ? '${((_currentStep + 1) / 8 * 100).round()}%' : '✓ Done',
            style: TextStyle(
              color: _currentStep < 8 ? _C.background : _C.success,
              fontSize: 12, fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ]),
    );
  }

  // ─── Step Progress Dots ──────────────────────────────────────────────────────

  Widget _buildStepProgress() {
    return Container(
      color: _C.surface,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Column(children: [
        Row(children: List.generate(8, (i) {
          final done    = i < _currentStep;
          final current = i == _currentStep;
          return Expanded(child: Row(children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: current ? 28 : 20,
              height: 20,
              decoration: BoxDecoration(
                gradient: done || current ? _C.primaryGradient : null,
                color: done || current ? null : _C.surfaceVar,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: done || current ? _C.primary : _C.border,
                  width: current ? 0 : 1,
                ),
              ),
              child: Center(
                child: done
                    ? const Icon(Icons.check_rounded, color: _C.background, size: 12)
                    : Text(
                        '${i + 1}',
                        style: TextStyle(
                          color: current ? _C.background : _C.textHint,
                          fontSize: 10, fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
            ),
            if (i < 7)
              Expanded(
                child: Container(
                  height: 2,
                  color: i < _currentStep ? _C.primary : _C.border,
                ),
              ),
          ]));
        })),
      ]),
    );
  }

  // ─── Nav Buttons ────────────────────────────────────────────────────────────

  Widget _buildNavButtons() {
    return Container(
      padding: EdgeInsets.only(
        left: 20, right: 20, top: 12,
        bottom: MediaQuery.of(context).padding.bottom + 12,
      ),
      decoration: BoxDecoration(
        color: _C.surface,
        border: Border(top: BorderSide(color: _C.border)),
      ),
      child: GestureDetector(
        onTap: _nextStep,
        child: Container(
          height: 52,
          decoration: BoxDecoration(
            gradient: _C.primaryGradient,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Center(
            child: Text(
              _currentStep == 7 ? 'Submit Registration' : 'Continue',
              style: const TextStyle(
                color: _C.background, fontSize: 16,
                fontWeight: FontWeight.w700, letterSpacing: 0.5,
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ════════════════════════════════════════════════════════════════════════════
  // STEP 1 — Personal Details
  // ════════════════════════════════════════════════════════════════════════════

  Widget _buildStep1() {
    return FadeTransition(
      opacity: _fadeAnim,
      child: Form(
        key: _s1Form,
        child: ListView(padding: const EdgeInsets.all(20), children: [
          _sectionLabel('Profile Photo'),
          const SizedBox(height: 16),
          _buildProfilePhotoWidget(),
          const SizedBox(height: 28),
          _sectionLabel('Personal Information'),
          const SizedBox(height: 16),
          _field(ctrl: _nameCtrl, label: 'Full Name', hint: 'Enter full name',
              icon: Icons.person_outline_rounded,
              inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z ]'))],
              validator: (v) => v == null || v.trim().length < 3 ? 'Enter valid full name' : null),
          const SizedBox(height: 16),
          _readonlyField(label: 'Mobile Number', value: widget.mobileNumber, icon: Icons.phone_outlined),
          const SizedBox(height: 16),
          _field(ctrl: _altMobCtrl, label: 'Alternative Mobile (Optional)',
              hint: 'Enter alternative number', icon: Icons.phone_callback_outlined,
              keyboardType: TextInputType.phone,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(10)],
              validator: (v) {
                if (v != null && v.isNotEmpty && v.length != 10) return 'Enter valid 10-digit number';
                return null;
              }),
          const SizedBox(height: 16),
          _field(ctrl: _emailCtrl, label: 'Email Address', hint: 'Enter email address',
              icon: Icons.email_outlined, keyboardType: TextInputType.emailAddress,
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'Email is required';
                if (!RegExp(r'^[\w-.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(v)) return 'Enter valid email';
                return null;
              }),
          const SizedBox(height: 16),
          _tapField(ctrl: _dobCtrl, label: 'Date of Birth', hint: 'Select date of birth',
              icon: Icons.calendar_today_outlined, onTap: _selectDob,
              validator: (v) => v == null || v.isEmpty ? 'Date of birth is required' : null),
          const SizedBox(height: 16),
          _dropdownField(
            label: 'Gender', hint: 'Select gender', icon: Icons.wc_outlined,
            value: _gender, items: ['Male', 'Female', 'Other'],
            onChanged: (v) => setState(() => _gender = v),
            validator: (v) => v == null ? 'Please select gender' : null,
          ),
          const SizedBox(height: 28),
          _sectionLabel('Login Security PIN'),
          const SizedBox(height: 4),
          const Text('This 4-digit PIN will be used for quick future logins',
              style: TextStyle(color: _C.textHint, fontSize: 12)),
          const SizedBox(height: 16),
          _pinField(ctrl: _pinCtrl, label: 'Create 4 Digit PIN',
              visible: _pinVisible, onToggle: () => setState(() => _pinVisible = !_pinVisible),
              validator: (v) {
                if (v == null || v.isEmpty) return 'PIN is required';
                if (v.length != 4) return 'PIN must be exactly 4 digits';
                return null;
              }),
          const SizedBox(height: 16),
          _pinField(ctrl: _pinConfCtrl, label: 'Confirm 4 Digit PIN',
              visible: _pinConfVisible, onToggle: () => setState(() => _pinConfVisible = !_pinConfVisible),
              validator: (v) {
                if (v == null || v.isEmpty) return 'Please confirm PIN';
                if (v.length != 4) return 'PIN must be exactly 4 digits';
                if (v != _pinCtrl.text) return 'PINs do not match';
                return null;
              }),
          const SizedBox(height: 20),
        ]),
      ),
    );
  }

  Widget _buildProfilePhotoWidget() {
    return Center(
      child: GestureDetector(
        onTap: () => _showPhotoPicker((f) => setState(() => _profilePhoto = f)),
        child: Stack(children: [
          Container(
            width: 100, height: 100,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: _C.primary, width: 2),
            ),
            child: ClipOval(
              child: _profilePhoto != null
                  ? Image.file(_profilePhoto!, fit: BoxFit.cover)
                  : Container(
                      color: _C.surfaceVar,
                      child: const Icon(Icons.person_outline_rounded, color: _C.textHint, size: 44),
                    ),
            ),
          ),
          Positioned(
            bottom: 2, right: 2,
            child: Container(
              width: 30, height: 30,
              decoration: BoxDecoration(
                gradient: _C.primaryGradient, shape: BoxShape.circle,
                border: Border.all(color: _C.background, width: 2),
              ),
              child: const Icon(Icons.camera_alt_rounded, color: _C.background, size: 14),
            ),
          ),
        ]),
      ),
    );
  }

  Future<void> _selectDob() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _dob ?? DateTime(now.year - 20),
      firstDate: DateTime(now.year - 60),
      lastDate: DateTime(now.year - 18),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.dark(
            primary: _C.primary, onPrimary: _C.background,
            surface: _C.surfaceVar, onSurface: _C.textPrimary,
          ),
          dialogBackgroundColor: _C.surface,
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      setState(() {
        _dob = picked;
        _dobCtrl.text =
            '${picked.day.toString().padLeft(2, '0')}/${picked.month.toString().padLeft(2, '0')}/${picked.year}';
      });
    }
  }

  // ════════════════════════════════════════════════════════════════════════════
  // STEP 2 — Address Details
  // ════════════════════════════════════════════════════════════════════════════

  Widget _buildStep2() {
    return FadeTransition(
      opacity: _fadeAnim,
      child: Form(
        key: _s2Form,
        child: ListView(padding: const EdgeInsets.all(20), children: [
          _sectionLabel('Current Location'),
          const SizedBox(height: 16),
          GestureDetector(
            onTap: _fetchLocation,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
              decoration: BoxDecoration(
                gradient: _C.primaryGradient,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                if (_locationLoading)
                  const SizedBox(width: 18, height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2, color: _C.background))
                else
                  const Icon(Icons.my_location_rounded, color: _C.background, size: 20),
                const SizedBox(width: 10),
                Text(
                  _locationLoading ? 'Fetching location...' : 'Use Current Location',
                  style: const TextStyle(color: _C.background, fontSize: 15, fontWeight: FontWeight.w600),
                ),
              ]),
            ),
          ),
          const SizedBox(height: 16),
          _field(ctrl: _currAddrCtrl, label: 'Current Address', hint: 'Auto-filled or type manually',
              icon: Icons.location_on_outlined, maxLines: 2,
              validator: (v) => v == null || v.trim().isEmpty ? 'Address is required' : null),
          const SizedBox(height: 16),
          Row(children: [
            Expanded(child: _readonlyField(label: 'Latitude', value: _latCtrl.text, icon: Icons.explore_outlined)),
            const SizedBox(width: 12),
            Expanded(child: _readonlyField(label: 'Longitude', value: _lngCtrl.text, icon: Icons.explore_outlined)),
          ]),
          const SizedBox(height: 28),
          _sectionLabel('Permanent Address'),
          const SizedBox(height: 16),
          _field(ctrl: _permAddrCtrl, label: 'Permanent Address', hint: 'Enter permanent address',
              icon: Icons.home_outlined, maxLines: 2,
              validator: (v) => v == null || v.trim().isEmpty ? 'Permanent address is required' : null),
          const SizedBox(height: 16),
          _field(ctrl: _cityCtrl, label: 'City', hint: 'Enter city',
              icon: Icons.location_city_outlined,
              validator: (v) => v == null || v.trim().isEmpty ? 'City is required' : null),
          const SizedBox(height: 16),
          _field(ctrl: _stateCtrl, label: 'State', hint: 'Enter state',
              icon: Icons.map_outlined,
              validator: (v) => v == null || v.trim().isEmpty ? 'State is required' : null),
          const SizedBox(height: 16),
          _field(ctrl: _pincodeCtrl, label: 'Pincode', hint: 'Enter 6-digit pincode',
              icon: Icons.pin_drop_outlined, keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(6)],
              validator: (v) {
                if (v == null || v.isEmpty) return 'Pincode is required';
                if (v.length != 6) return 'Enter valid 6-digit pincode';
                return null;
              }),
          const SizedBox(height: 20),
        ]),
      ),
    );
  }

  // ════════════════════════════════════════════════════════════════════════════
  // STEP 3 — Vehicle Details
  // ════════════════════════════════════════════════════════════════════════════

  Widget _buildStep3() {
    return FadeTransition(
      opacity: _fadeAnim,
      child: Form(
        key: _s3Form,
        child: ListView(padding: const EdgeInsets.all(20), children: [
          _sectionLabel('Vehicle Information'),
          const SizedBox(height: 16),
          _dropdownField(
            label: 'Vehicle Type', hint: 'Select vehicle type', icon: Icons.two_wheeler_outlined,
            value: _vehicleType,
            items: ['Bicycle', 'Electric Bike', 'Bike', 'Scooty'],
            onChanged: (v) => setState(() { _vehicleType = v; _eBikeType = null; }),
            validator: (v) => v == null ? 'Select vehicle type' : null,
          ),
          if (_vehicleType == 'Electric Bike') ...[
            const SizedBox(height: 16),
            _sectionLabel('Electric Bike Type'),
            const SizedBox(height: 12),
            Row(children: [
              Expanded(child: _selectCard('Low Speed', 'Below 25 KM/H',
                  _eBikeType == 'Low Speed', () => setState(() => _eBikeType = 'Low Speed'))),
              const SizedBox(width: 12),
              Expanded(child: _selectCard('High Speed', 'Above 25 KM/H',
                  _eBikeType == 'High Speed', () => setState(() => _eBikeType = 'High Speed'))),
            ]),
          ],
          const SizedBox(height: 16),
          if (_vehicleType != null) ..._buildVehicleFields(),
          const SizedBox(height: 20),
        ]),
      ),
    );
  }

  List<Widget> _buildVehicleFields() {
    final isBicycle  = _vehicleType == 'Bicycle';
    final isLowSpeed = _vehicleType == 'Electric Bike' && _eBikeType == 'Low Speed';
    final needsVehNum = !isBicycle && !isLowSpeed;
    final needsDocs   = _vehicleType == 'Bike' || _vehicleType == 'Scooty' ||
        (_vehicleType == 'Electric Bike' && _eBikeType == 'High Speed');

    return [
      _photoUploadTile(
        label: isBicycle ? 'Bicycle Photo *' : 'Vehicle Photo *',
        file: _vehiclePhoto,
        onTap: () => _showPhotoPicker((f) => setState(() => _vehiclePhoto = f)),
      ),
      if (isBicycle || isLowSpeed) ...[
        const SizedBox(height: 16),
        _field(
          ctrl: _bikeBrandCtrl,
          label: isBicycle ? 'Brand / Model (Optional)' : 'Brand Name',
          hint: 'e.g. Hero, Yulu',
          icon: Icons.branding_watermark_outlined,
        ),
      ],
      if (isLowSpeed) ...[
        const SizedBox(height: 16),
        _field(ctrl: _bikeModelCtrl, label: 'Model Name', hint: 'Enter model name',
            icon: Icons.electric_bike_outlined,
            validator: (v) => v == null || v.isEmpty ? 'Model name is required' : null),
        const SizedBox(height: 16),
        _field(ctrl: _batteryCtrl, label: 'Battery Details', hint: 'e.g. 48V 20Ah Lithium',
            icon: Icons.battery_charging_full_outlined,
            validator: (v) => v == null || v.isEmpty ? 'Battery details required' : null),
      ],
      if (needsVehNum) ...[
        const SizedBox(height: 16),
        _field(ctrl: _vehNumCtrl, label: 'Vehicle Number *', hint: 'e.g. MH12AB1234',
            icon: Icons.confirmation_number_outlined,
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[A-Za-z0-9]')),
              LengthLimitingTextInputFormatter(12),
            ],
            validator: (v) => v == null || v.trim().isEmpty ? 'Vehicle number is required' : null),
      ],
      if (needsDocs) ...[
        const SizedBox(height: 16),
        _photoUploadTile(label: 'RC Document *', file: _rcPhoto,
            onTap: () => _showPhotoPicker((f) => setState(() => _rcPhoto = f))),
        const SizedBox(height: 16),
        _field(ctrl: _dlNumCtrl, label: 'Driving License Number *', hint: 'Enter DL number',
            icon: Icons.badge_outlined,
            validator: (v) => v == null || v.trim().isEmpty ? 'DL number is required' : null),
        const SizedBox(height: 16),
        Row(children: [
          Expanded(child: _photoUploadTile(label: 'License Front *', file: _dlFront,
              onTap: () => _showPhotoPicker((f) => setState(() => _dlFront = f)))),
          const SizedBox(width: 12),
          Expanded(child: _photoUploadTile(label: 'License Back *', file: _dlBack,
              onTap: () => _showPhotoPicker((f) => setState(() => _dlBack = f)))),
        ]),
      ],
    ];
  }

  // ════════════════════════════════════════════════════════════════════════════
  // STEP 4 — Document Verification
  // ════════════════════════════════════════════════════════════════════════════

  Widget _buildStep4() {
    return FadeTransition(
      opacity: _fadeAnim,
      child: Form(
        key: _s4Form,
        child: ListView(padding: const EdgeInsets.all(20), children: [
          _sectionLabel('Aadhaar Card'),
          const SizedBox(height: 16),
          _field(ctrl: _aadhaarCtrl, label: 'Aadhaar Number *', hint: 'Enter 12-digit Aadhaar number',
              icon: Icons.credit_card_outlined, keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(12)],
              validator: (v) {
                if (v == null || v.isEmpty) return 'Aadhaar number is required';
                if (v.length != 12) return 'Aadhaar must be exactly 12 digits';
                return null;
              }),
          const SizedBox(height: 16),
          Row(children: [
            Expanded(child: _photoUploadTile(label: 'Aadhaar Front *', file: _aadhaarFront,
                onTap: () => _showPhotoPicker((f) => setState(() => _aadhaarFront = f)))),
            const SizedBox(width: 12),
            Expanded(child: _photoUploadTile(label: 'Aadhaar Back *', file: _aadhaarBack,
                onTap: () => _showPhotoPicker((f) => setState(() => _aadhaarBack = f)))),
          ]),
          const SizedBox(height: 28),
          _sectionLabel('PAN Card'),
          const SizedBox(height: 16),
          _field(ctrl: _panCtrl, label: 'PAN Number *', hint: 'e.g. ABCDE1234F',
              icon: Icons.credit_card_outlined,
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[A-Za-z0-9]')),
                LengthLimitingTextInputFormatter(10),
              ],
              validator: (v) {
                if (v == null || v.isEmpty) return 'PAN number is required';
                if (!RegExp(r'^[A-Z]{5}[0-9]{4}[A-Z]{1}$').hasMatch(v.toUpperCase())) {
                  return 'Invalid PAN format (e.g. ABCDE1234F)';
                }
                return null;
              }),
          const SizedBox(height: 16),
          _photoUploadTile(label: 'PAN Card Image *', file: _panPhoto,
              onTap: () => _showPhotoPicker((f) => setState(() => _panPhoto = f))),
          const SizedBox(height: 28),
          _sectionLabel('Selfie Verification'),
          const SizedBox(height: 8),
          const Text('Capture a live selfie for identity verification',
              style: TextStyle(color: _C.textHint, fontSize: 12)),
          const SizedBox(height: 16),
          GestureDetector(
            onTap: () => _showPhotoPicker((f) => setState(() => _selfie = f), selfieOnly: true),
            child: Container(
              height: 160,
              decoration: BoxDecoration(
                color: _C.surfaceVar,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: _selfie != null ? _C.primary : _C.border,
                  width: _selfie != null ? 1.5 : 1,
                ),
              ),
              child: _selfie != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(15),
                      child: Image.file(_selfie!, fit: BoxFit.cover))
                  : Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                      Container(
                        width: 56, height: 56,
                        decoration: BoxDecoration(
                          gradient: _C.primaryGradient,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.face_retouching_natural_outlined,
                            color: _C.background, size: 28),
                      ),
                      const SizedBox(height: 12),
                      const Text('Tap to capture selfie',
                          style: TextStyle(color: _C.textSecondary, fontSize: 14, fontWeight: FontWeight.w500)),
                      const SizedBox(height: 4),
                      const Text('Use front camera only',
                          style: TextStyle(color: _C.textHint, fontSize: 12)),
                    ]),
            ),
          ),
          const SizedBox(height: 20),
        ]),
      ),
    );
  }

  // ════════════════════════════════════════════════════════════════════════════
  // STEP 5 — Bank Details
  // ════════════════════════════════════════════════════════════════════════════

  Widget _buildStep5() {
    return FadeTransition(
      opacity: _fadeAnim,
      child: Form(
        key: _s5Form,
        child: ListView(padding: const EdgeInsets.all(20), children: [
          _sectionLabel('Bank Account Details'),
          const SizedBox(height: 16),
          _field(ctrl: _accHolderCtrl, label: 'Account Holder Name *', hint: 'As per bank records',
              icon: Icons.person_outline_rounded,
              inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z ]'))],
              validator: (v) => v == null || v.trim().isEmpty ? 'Account holder name required' : null),
          const SizedBox(height: 16),
          _field(ctrl: _accNumCtrl, label: 'Account Number *', hint: 'Enter account number',
              icon: Icons.account_balance_outlined, keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              obscureText: true,
              validator: (v) => v == null || v.trim().isEmpty ? 'Account number is required' : null),
          const SizedBox(height: 16),
          _field(ctrl: _accConfCtrl, label: 'Confirm Account Number *', hint: 'Re-enter account number',
              icon: Icons.account_balance_outlined, keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'Please confirm account number';
                if (v != _accNumCtrl.text) return 'Account numbers do not match';
                return null;
              }),
          const SizedBox(height: 16),
          _dropdownField(
            label: 'Bank Name *', hint: 'Select bank', icon: Icons.account_balance_outlined,
            value: _bankName,
            items: ['State Bank of India', 'HDFC Bank', 'ICICI Bank', 'Axis Bank',
                'Punjab National Bank', 'Bank of Baroda', 'Canara Bank',
                'Union Bank', 'Kotak Mahindra Bank', 'Yes Bank', 'Other'],
            onChanged: (v) => setState(() => _bankName = v),
            validator: (v) => v == null ? 'Please select bank' : null,
          ),
          const SizedBox(height: 16),
          _field(ctrl: _ifscCtrl, label: 'IFSC Code *', hint: 'e.g. SBIN0001234',
              icon: Icons.code_outlined,
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[A-Za-z0-9]')),
                LengthLimitingTextInputFormatter(11),
              ],
              validator: (v) {
                if (v == null || v.isEmpty) return 'IFSC code is required';
                if (!RegExp(r'^[A-Z]{4}0[A-Z0-9]{6}$').hasMatch(v.toUpperCase())) {
                  return 'Invalid IFSC format (e.g. SBIN0001234)';
                }
                return null;
              }),
          const SizedBox(height: 16),
          _field(ctrl: _branchCtrl, label: 'Branch Name *', hint: 'Enter branch name',
              icon: Icons.store_outlined,
              validator: (v) => v == null || v.trim().isEmpty ? 'Branch name is required' : null),
          const SizedBox(height: 16),
          _field(ctrl: _upiCtrl, label: 'UPI ID (Optional)', hint: 'e.g. name@upi',
              icon: Icons.payment_outlined,
              validator: (v) {
                if (v != null && v.isNotEmpty) {
                  if (!RegExp(r'^[\w.-]+@[\w.-]+$').hasMatch(v)) return 'Invalid UPI ID';
                }
                return null;
              }),
          const SizedBox(height: 20),
        ]),
      ),
    );
  }

  // ════════════════════════════════════════════════════════════════════════════
  // STEP 6 — Emergency Details
  // ════════════════════════════════════════════════════════════════════════════

  Widget _buildStep6() {
    return FadeTransition(
      opacity: _fadeAnim,
      child: Form(
        key: _s6Form,
        child: ListView(padding: const EdgeInsets.all(20), children: [
          _sectionLabel('Emergency Contact'),
          const SizedBox(height: 8),
          const Text('This contact will be reached in case of emergency',
              style: TextStyle(color: _C.textHint, fontSize: 12)),
          const SizedBox(height: 20),
          _field(ctrl: _emergNameCtrl, label: 'Contact Name *', hint: 'Enter emergency contact name',
              icon: Icons.person_pin_outlined,
              inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z ]'))],
              validator: (v) => v == null || v.trim().isEmpty ? 'Contact name is required' : null),
          const SizedBox(height: 16),
          _dropdownField(
            label: 'Relation *', hint: 'Select relation', icon: Icons.family_restroom_outlined,
            value: _relation,
            items: ['Father', 'Mother', 'Brother', 'Sister', 'Wife', 'Husband', 'Friend', 'Other'],
            onChanged: (v) => setState(() => _relation = v),
            validator: (v) => v == null ? 'Please select relation' : null,
          ),
          const SizedBox(height: 16),
          _field(ctrl: _emergMobCtrl, label: 'Mobile Number *', hint: 'Enter 10-digit mobile number',
              icon: Icons.phone_outlined, keyboardType: TextInputType.phone,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(10)],
              validator: (v) {
                if (v == null || v.isEmpty) return 'Mobile number is required';
                if (v.length != 10) return 'Enter valid 10-digit mobile number';
                return null;
              }),
          const SizedBox(height: 20),
        ]),
      ),
    );
  }

  // ════════════════════════════════════════════════════════════════════════════
  // STEP 7 — Work Preference
  // ════════════════════════════════════════════════════════════════════════════

  Widget _buildStep7() {
    return FadeTransition(
      opacity: _fadeAnim,
      child: Form(
        key: _s7Form,
        child: ListView(padding: const EdgeInsets.all(20), children: [
          _sectionLabel('Delivery Category'),
          const SizedBox(height: 8),
          const Text('All delivery categories are assigned by default',
              style: TextStyle(color: _C.textHint, fontSize: 12)),
          const SizedBox(height: 16),
          Row(children: [
            Expanded(child: _categoryBadge(Icons.shopping_cart_outlined, 'Grocery')),
            const SizedBox(width: 10),
            Expanded(child: _categoryBadge(Icons.restaurant_outlined, 'Restaurant')),
            const SizedBox(width: 10),
            Expanded(child: _categoryBadge(Icons.medical_services_outlined, 'Medicine')),
          ]),
          const SizedBox(height: 28),
          _sectionLabel('Work Type'),
          const SizedBox(height: 16),
          Row(children: [
            Expanded(child: _selectCard('Full Time', '7 AM - 8 PM',
                _workType == 'Full Time', () => setState(() { _workType = 'Full Time'; _shift = null; }))),
            const SizedBox(width: 12),
            Expanded(child: _selectCard('Part Time', 'Flexible Shift',
                _workType == 'Part Time', () => setState(() => _workType = 'Part Time'))),
          ]),
          if (_workType == 'Full Time') ...[
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _C.surfaceVar,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: _C.primary.withOpacity(0.3)),
              ),
              child: Row(children: [
                const Icon(Icons.schedule_outlined, color: _C.primary, size: 22),
                const SizedBox(width: 12),
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: const [
                  Text('Working Hours', style: TextStyle(color: _C.textSecondary, fontSize: 12)),
                  SizedBox(height: 2),
                  Text('7:00 AM — 8:00 PM', style: TextStyle(color: _C.textPrimary, fontSize: 15, fontWeight: FontWeight.w600)),
                ]),
              ]),
            ),
          ],
          if (_workType == 'Part Time') ...[
            const SizedBox(height: 20),
            _sectionLabel('Select Shift *'),
            const SizedBox(height: 14),
            _shiftCard('Morning Shift', '7:00 AM — 1:00 PM', Icons.wb_sunny_outlined, _shift == 'Morning',
                () => setState(() => _shift = 'Morning')),
            const SizedBox(height: 12),
            _shiftCard('Afternoon Shift', '2:00 PM — 8:00 PM', Icons.wb_twilight_outlined, _shift == 'Afternoon',
                () => setState(() => _shift = 'Afternoon')),
          ],
          const SizedBox(height: 20),
        ]),
      ),
    );
  }

  Widget _categoryBadge(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
      decoration: BoxDecoration(
        gradient: _C.primaryGradient,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(children: [
        Icon(icon, color: _C.background, size: 24),
        const SizedBox(height: 6),
        Text(label, style: const TextStyle(color: _C.background, fontSize: 12, fontWeight: FontWeight.w600)),
      ]),
    );
  }

  Widget _shiftCard(String title, String time, IconData icon, bool selected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: selected ? _C.primary.withOpacity(0.1) : _C.surfaceVar,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: selected ? _C.primary : _C.border, width: selected ? 1.5 : 1),
        ),
        child: Row(children: [
          Container(
            width: 44, height: 44,
            decoration: BoxDecoration(
              gradient: selected ? _C.primaryGradient : null,
              color: selected ? null : _C.card,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: selected ? _C.background : _C.textHint, size: 22),
          ),
          const SizedBox(width: 14),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(title, style: TextStyle(color: selected ? _C.primary : _C.textPrimary,
                fontSize: 15, fontWeight: FontWeight.w600)),
            const SizedBox(height: 2),
            Text(time, style: const TextStyle(color: _C.textSecondary, fontSize: 12)),
          ]),
          const Spacer(),
          if (selected) const Icon(Icons.check_circle_rounded, color: _C.primary, size: 22),
        ]),
      ),
    );
  }

  // ════════════════════════════════════════════════════════════════════════════
  // STEP 8 — Agreement
  // ════════════════════════════════════════════════════════════════════════════

  Widget _buildStep8() {
    final isFull  = _workType == 'Full Time';
    final isMorn  = _shift == 'Morning';
    final timing  = isFull ? '7:00 AM – 8:00 PM' : (isMorn ? '7:00 AM – 1:00 PM' : '2:00 PM – 8:00 PM');
    final typeStr = isFull ? 'Full Time' : (isMorn ? 'Morning Shift' : 'Afternoon Shift');

    return FadeTransition(
      opacity: _fadeAnim,
      child: ListView(padding: const EdgeInsets.all(20), children: [
        _sectionLabel('Delivery Partner Agreement'),
        const SizedBox(height: 8),
        Text('CartKaro $typeStr Agreement',
            style: const TextStyle(color: _C.textSecondary, fontSize: 13)),
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: _C.surfaceVar,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: _C.border),
          ),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            _agreementItem(Icons.local_shipping_outlined, 'Delivery Rules',
                'Complete all assigned deliveries within the stipulated time frame. Handle all packages with care and professionalism. Report any issues to support immediately.'),
            const Divider(color: _C.divider, height: 24),
            _agreementItem(Icons.payments_outlined, 'Payment Policy',
                'Earnings will be calculated per delivery and credited weekly. Bonuses apply for high ratings and on-time deliveries. Deductions may apply for cancellations or misconduct.'),
            const Divider(color: _C.divider, height: 24),
            _agreementItem(Icons.health_and_safety_outlined, 'Safety Rules',
                'Always follow traffic rules and wear a helmet. Maintain your vehicle in working condition. Do not carry restricted items or exceed vehicle capacity.'),
            const Divider(color: _C.divider, height: 24),
            _agreementItem(Icons.assignment_ind_outlined, 'Partner Responsibility',
                'Maintain a professional attitude with customers. Keep your app updated and active during working hours: $timing. Report damages or accidents within 24 hours.'),
          ]),
        ),
        const SizedBox(height: 20),
        _linkRow('Terms & Conditions'),
        const SizedBox(height: 10),
        _linkRow('Privacy Policy'),
        const SizedBox(height: 20),
        GestureDetector(
          onTap: () => setState(() => _agreementAccepted = !_agreementAccepted),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _agreementAccepted ? _C.primary.withOpacity(0.08) : _C.surfaceVar,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: _agreementAccepted ? _C.primary : _C.border,
                width: _agreementAccepted ? 1.5 : 1,
              ),
            ),
            child: Row(children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 22, height: 22,
                decoration: BoxDecoration(
                  gradient: _agreementAccepted ? _C.primaryGradient : null,
                  color: _agreementAccepted ? null : _C.card,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: _agreementAccepted ? _C.primary : _C.border,
                  ),
                ),
                child: _agreementAccepted
                    ? const Icon(Icons.check_rounded, color: _C.background, size: 14)
                    : null,
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'I have read and agree to the CartKaro Delivery Partner Agreement, Terms & Conditions, and Privacy Policy.',
                  style: TextStyle(color: _C.textPrimary, fontSize: 13, height: 1.5),
                ),
              ),
            ]),
          ),
        ),
        const SizedBox(height: 20),
      ]),
    );
  }

  Widget _agreementItem(IconData icon, String title, String desc) {
    return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Container(
        width: 36, height: 36,
        decoration: BoxDecoration(gradient: _C.primaryGradient, borderRadius: BorderRadius.circular(8)),
        child: Icon(icon, color: _C.background, size: 18),
      ),
      const SizedBox(width: 12),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title, style: const TextStyle(color: _C.textPrimary, fontSize: 14, fontWeight: FontWeight.w600)),
        const SizedBox(height: 4),
        Text(desc, style: const TextStyle(color: _C.textSecondary, fontSize: 12, height: 1.5)),
      ])),
    ]);
  }

  Widget _linkRow(String label) {
    return Row(children: [
      const Icon(Icons.open_in_new_rounded, color: _C.primary, size: 16),
      const SizedBox(width: 8),
      Text(label, style: const TextStyle(color: _C.primary, fontSize: 14,
          decoration: TextDecoration.underline, decorationColor: _C.primary)),
    ]);
  }

  // ════════════════════════════════════════════════════════════════════════════
  // STEP 9 — Submitted
  // ════════════════════════════════════════════════════════════════════════════

  Widget _buildStep9() {
    return FadeTransition(
      opacity: _fadeAnim,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(children: [
          const SizedBox(height: 20),
          Container(
            width: 90, height: 90,
            decoration: const BoxDecoration(gradient: _C.primaryGradient, shape: BoxShape.circle),
            child: const Icon(Icons.check_rounded, color: _C.background, size: 48),
          ),
          const SizedBox(height: 24),
          ShaderMask(
            shaderCallback: (b) => _C.primaryGradient.createShader(b),
            child: const Text(
              'Registration Submitted\nSuccessfully!',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w700, height: 1.3),
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Your details have been sent for verification.\nPlease wait 24–48 hours for approval.',
            textAlign: TextAlign.center,
            style: TextStyle(color: _C.textSecondary, fontSize: 14, height: 1.6),
          ),
          const SizedBox(height: 32),
          _sectionLabel('Verification Status'),
          const SizedBox(height: 16),
          _verificationItem('Profile Details', true),
          _verificationItem('Documents', true),
          _verificationItem('Vehicle Details', true),
          _verificationItem('Bank Details', true),
          const SizedBox(height: 32),
          GestureDetector(
            onTap: () => context.go('/dashboard'),
            child: Container(
              height: 52,
              decoration: BoxDecoration(
                gradient: _C.primaryGradient,
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Center(
                child: Text('Go to Dashboard',
                    style: TextStyle(color: _C.background, fontSize: 16, fontWeight: FontWeight.w700)),
              ),
            ),
          ),
          const SizedBox(height: 14),
          GestureDetector(
            onTap: _openSupport,
            child: Container(
              height: 52,
              decoration: BoxDecoration(
                color: _C.surfaceVar,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: _C.border),
              ),
              child: const Center(
                child: Text('Help & Support',
                    style: TextStyle(color: _C.textPrimary, fontSize: 16, fontWeight: FontWeight.w600)),
              ),
            ),
          ),
          const SizedBox(height: 20),
        ]),
      ),
    );
  }

  Widget _verificationItem(String label, bool done) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
      decoration: BoxDecoration(
        color: _C.surfaceVar,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: done ? _C.primary.withOpacity(0.3) : _C.border),
      ),
      child: Row(children: [
        Container(
          width: 28, height: 28,
          decoration: BoxDecoration(
            gradient: done ? _C.primaryGradient : null,
            color: done ? null : _C.card,
            shape: BoxShape.circle,
          ),
          child: Icon(done ? Icons.check_rounded : Icons.access_time_rounded,
              color: done ? _C.background : _C.textHint, size: 14),
        ),
        const SizedBox(width: 14),
        Text(label, style: const TextStyle(color: _C.textPrimary, fontSize: 14, fontWeight: FontWeight.w500)),
        const Spacer(),
        Text(done ? 'Submitted' : 'Pending',
            style: TextStyle(color: done ? _C.success : _C.warning, fontSize: 12, fontWeight: FontWeight.w600)),
      ]),
    );
  }

  Future<void> _openSupport() async {
    showModalBottomSheet(
      context: context,
      backgroundColor: _C.surfaceVar,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            const Text('Need Help?',
                style: TextStyle(color: _C.textPrimary, fontSize: 20, fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            const Text('Our support team is available during business hours',
                textAlign: TextAlign.center,
                style: TextStyle(color: _C.textSecondary, fontSize: 13)),
            const SizedBox(height: 24),
            GestureDetector(
              onTap: () async {
                final uri = Uri(scheme: 'tel', path: '+919999999999');
                if (await canLaunchUrl(uri)) await launchUrl(uri);
              },
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: _C.primaryGradient,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(mainAxisAlignment: MainAxisAlignment.center, children: const [
                  Icon(Icons.call_rounded, color: _C.background, size: 22),
                  SizedBox(width: 10),
                  Text('Call Support: +91 9999999999',
                      style: TextStyle(color: _C.background, fontSize: 15, fontWeight: FontWeight.w700)),
                ]),
              ),
            ),
            const SizedBox(height: 8),
          ]),
        ),
      ),
    );
  }

  // ════════════════════════════════════════════════════════════════════════════
  // SHARED WIDGETS
  // ════════════════════════════════════════════════════════════════════════════

  Widget _sectionLabel(String label) {
    return Row(children: [
      Container(
        width: 3, height: 18,
        decoration: BoxDecoration(gradient: _C.primaryGradient, borderRadius: BorderRadius.circular(2)),
      ),
      const SizedBox(width: 10),
      Text(label, style: const TextStyle(color: _C.textPrimary, fontSize: 15, fontWeight: FontWeight.w600)),
    ]);
  }

  Widget _field({
    required TextEditingController ctrl,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    String? Function(String?)? validator,
    bool obscureText = false,
    int maxLines = 1,
  }) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      if (label.isNotEmpty) ...[
        Text(label, style: const TextStyle(color: _C.textSecondary, fontSize: 13, fontWeight: FontWeight.w500)),
        const SizedBox(height: 8),
      ],
      TextFormField(
        controller: ctrl,
        keyboardType: keyboardType,
        inputFormatters: inputFormatters,
        obscureText: obscureText,
        maxLines: obscureText ? 1 : maxLines,
        style: const TextStyle(color: _C.textPrimary, fontSize: 15),
        decoration: _dec(hint: hint, icon: icon),
        validator: validator,
      ),
    ]);
  }

  Widget _tapField({
    required TextEditingController ctrl,
    required String label,
    required String hint,
    required IconData icon,
    required VoidCallback onTap,
    String? Function(String?)? validator,
  }) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: const TextStyle(color: _C.textSecondary, fontSize: 13, fontWeight: FontWeight.w500)),
      const SizedBox(height: 8),
      TextFormField(
        controller: ctrl, readOnly: true, onTap: onTap,
        style: const TextStyle(color: _C.textPrimary, fontSize: 15),
        decoration: _dec(hint: hint, icon: icon, suffix: Icons.calendar_month_outlined),
        validator: validator,
      ),
    ]);
  }

  Widget _readonlyField({required String label, required String value, required IconData icon}) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: const TextStyle(color: _C.textSecondary, fontSize: 13, fontWeight: FontWeight.w500)),
      const SizedBox(height: 8),
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
        decoration: BoxDecoration(
          color: _C.card,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: _C.border),
        ),
        child: Row(children: [
          Icon(icon, color: _C.primary, size: 20),
          const SizedBox(width: 12),
          Expanded(child: Text(value.isEmpty ? '—' : value,
              style: const TextStyle(color: _C.textSecondary, fontSize: 15))),
          const Icon(Icons.lock_outline_rounded, color: _C.textHint, size: 16),
        ]),
      ),
    ]);
  }

  Widget _pinField({
    required TextEditingController ctrl,
    required String label,
    required bool visible,
    required VoidCallback onToggle,
    String? Function(String?)? validator,
  }) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: const TextStyle(color: _C.textSecondary, fontSize: 13, fontWeight: FontWeight.w500)),
      const SizedBox(height: 8),
      TextFormField(
        controller: ctrl,
        obscureText: !visible,
        keyboardType: TextInputType.number,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(4)],
        style: const TextStyle(color: _C.textPrimary, fontSize: 20, letterSpacing: 8, fontWeight: FontWeight.w700),
        textAlign: TextAlign.center,
        decoration: _dec(
          hint: '● ● ● ●', icon: Icons.lock_outline_rounded,
          suffix: visible ? Icons.visibility_outlined : Icons.visibility_off_outlined,
          onSuffixTap: onToggle,
        ),
        validator: validator,
      ),
    ]);
  }

  Widget _dropdownField({
    required String label,
    required String hint,
    required IconData icon,
    required String? value,
    required List<String> items,
    required void Function(String?) onChanged,
    String? Function(String?)? validator,
  }) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: const TextStyle(color: _C.textSecondary, fontSize: 13, fontWeight: FontWeight.w500)),
      const SizedBox(height: 8),
      DropdownButtonFormField<String>(
        value: value,
        dropdownColor: _C.surfaceVar,
        icon: const Icon(Icons.keyboard_arrow_down_rounded, color: _C.primary),
        style: const TextStyle(color: _C.textPrimary, fontSize: 15),
        decoration: _dec(hint: hint, icon: icon),
        items: items.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
        onChanged: onChanged,
        validator: validator,
      ),
    ]);
  }

  Widget _photoUploadTile({required String label, required File? file, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 110,
        decoration: BoxDecoration(
          color: _C.surfaceVar,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: file != null ? _C.primary : _C.border,
            width: file != null ? 1.5 : 1,
          ),
        ),
        child: file != null
            ? Stack(fit: StackFit.expand, children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(11),
                  child: Image.file(file, fit: BoxFit.cover),
                ),
                Positioned(
                  top: 6, right: 6,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(gradient: _C.primaryGradient, shape: BoxShape.circle),
                    child: const Icon(Icons.edit_rounded, color: _C.background, size: 12),
                  ),
                ),
              ])
            : Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                Container(
                  width: 38, height: 38,
                  decoration: BoxDecoration(gradient: _C.primaryGradient, borderRadius: BorderRadius.circular(10)),
                  child: const Icon(Icons.upload_rounded, color: _C.background, size: 20),
                ),
                const SizedBox(height: 8),
                Text(label, textAlign: TextAlign.center,
                    style: const TextStyle(color: _C.textSecondary, fontSize: 12, fontWeight: FontWeight.w500)),
              ]),
      ),
    );
  }

  Widget _selectCard(String title, String subtitle, bool selected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 14),
        decoration: BoxDecoration(
          color: selected ? _C.primary.withOpacity(0.1) : _C.surfaceVar,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: selected ? _C.primary : _C.border, width: selected ? 1.5 : 1),
        ),
        child: Column(children: [
          if (selected)
            const Icon(Icons.check_circle_rounded, color: _C.primary, size: 20)
          else
            const SizedBox(height: 20),
          const SizedBox(height: 6),
          Text(title, style: TextStyle(
            color: selected ? _C.primary : _C.textPrimary,
            fontSize: 14, fontWeight: FontWeight.w700,
          )),
          const SizedBox(height: 4),
          Text(subtitle, style: const TextStyle(color: _C.textHint, fontSize: 11), textAlign: TextAlign.center),
        ]),
      ),
    );
  }

  InputDecoration _dec({
    required String hint,
    required IconData icon,
    IconData? suffix,
    VoidCallback? onSuffixTap,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: _C.textHint, fontSize: 14),
      filled: true,
      fillColor: _C.surfaceVar,
      prefixIcon: Icon(icon, color: _C.primary, size: 20),
      suffixIcon: suffix != null
          ? GestureDetector(onTap: onSuffixTap,
              child: Icon(suffix, color: _C.textSecondary, size: 20))
          : null,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _C.border)),
      focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _C.primary, width: 1.5)),
      errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _C.error)),
      focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _C.error, width: 1.5)),
      errorStyle: const TextStyle(color: _C.error, fontSize: 12),
    );
  }
}