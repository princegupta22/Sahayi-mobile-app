import 'package:flutter/material.dart';
import 'app_language.dart';

/// A worker type (the "subcategory"). [en] is what gets stored in
/// `workers.category_en`, so never rename an existing English name.
class WorkCategory {
  final String en;
  final String ml;
  final IconData icon;
  final String groupId;
  const WorkCategory(this.en, this.ml, this.icon, this.groupId);

  String label(AppLanguage lang) => lang == AppLanguage.malayalam ? ml : en;

  /// Every subcategory across all groups (used by the Find Work form).
  static List<WorkCategory> get all => [
        for (final g in CategoryGroup.all) ...g.subs,
      ];

  static WorkCategory? byEnglish(String en) =>
      all.where((c) => c.en == en).firstOrNull;
}

/// A top-level category shown on the dashboard, with its subcategories.
class CategoryGroup {
  final String id;
  final String en;
  final String ml;
  final IconData icon;
  final Color color;
  final List<WorkCategory> subs;
  const CategoryGroup._(this.id, this.en, this.ml, this.icon, this.color, this.subs);

  String label(AppLanguage lang) => lang == AppLanguage.malayalam ? ml : en;

  /// Optional photo for the dashboard card. Drop a file with this name into
  /// assets/categories/ and it shows up; otherwise the icon tile is used.
  String get imageAsset => 'assets/categories/$id.jpg';

  /// "Electrician, Plumber, Carpenter…" in the current language.
  String preview(AppLanguage lang, {int count = 4}) {
    final names = subs.take(count).map((s) => s.label(lang)).join(', ');
    return subs.length > count ? '$names…' : names;
  }

  bool contains(String categoryEn) => subs.any((s) => s.en == categoryEn);

  static CategoryGroup? byId(String id) =>
      all.where((g) => g.id == id).firstOrNull;

  static CategoryGroup? ofCategory(String categoryEn) =>
      all.where((g) => g.contains(categoryEn)).firstOrNull;

  static CategoryGroup _g(
    String id,
    String en,
    String ml,
    IconData icon,
    Color color,
    List<(String, String, IconData?)> subs,
  ) =>
      CategoryGroup._(id, en, ml, icon, color, [
        for (final s in subs) WorkCategory(s.$1, s.$2, s.$3 ?? icon, id),
      ]);

  static final List<CategoryGroup> all = [
    _g('home', 'Home Services', 'ഹോം സർവീസുകൾ', Icons.home_repair_service_rounded,
        const Color(0xFF2E7D32), [
      ('Electrician', 'ഇലക്ട്രീഷ്യൻ', Icons.electrical_services),
      ('Plumber', 'പ്ലംബർ', Icons.plumbing),
      ('Carpenter', 'ആശാരി', Icons.carpenter),
      ('Painter', 'പെയിന്റർ', Icons.format_paint),
      ('AC Technician', 'എസി ടെക്നീഷ്യൻ', Icons.ac_unit),
      ('Welder', 'വെൽഡർ', Icons.local_fire_department),
      ('Tiles & Flooring Worker', 'ടൈൽസ് / ഫ്ലോറിംഗ് ജോലിക്കാരൻ', Icons.grid_view_rounded),
      ('False Ceiling Worker', 'ജിപ്സം / സീലിംഗ് ജോലിക്കാരൻ', Icons.layers_rounded),
      ('Waterproofing Worker', 'വാട്ടർപ്രൂഫിംഗ് ജോലിക്കാരൻ', Icons.water_drop),
      ('Glass & Aluminium Fabricator', 'ഗ്ലാസ് & അലുമിനിയം ഫാബ്രിക്കേറ്റർ', Icons.window_rounded),
      ('CCTV Technician', 'സിസിടിവി ടെക്നീഷ്യൻ', Icons.videocam_rounded),
      ('Solar & Inverter Technician', 'സോളാർ & ഇൻവെർട്ടർ ടെക്നീഷ്യൻ', Icons.solar_power),
      ('Water Purifier Technician', 'വാട്ടർ പ്യൂരിഫയർ ടെക്നീഷ്യൻ', Icons.water),
      ('Locksmith', 'ലോക്ക്സ്മിത്ത്', Icons.lock_rounded),
      ('Furniture Repair', 'ഫർണിച്ചർ റിപ്പയർ', Icons.chair_rounded),
      ('Curtain & Blinds Fitter', 'കർട്ടൻ / ബ്ലൈൻഡ്സ് ഫിറ്റർ', Icons.curtains_rounded),
    ]),
    _g('cleaning', 'Cleaning & Pest Control', 'ക്ലീനിംഗ് & കീട നിയന്ത്രണം',
        Icons.cleaning_services_rounded, const Color(0xFF00897B), [
      ('Cleaner', 'ക്ലീനർ', Icons.cleaning_services),
      ('Deep Cleaning', 'ഡീപ് ക്ലീനിംഗ്', Icons.auto_awesome),
      ('Water Tank Cleaning', 'വാട്ടർ ടാങ്ക് ക്ലീനിംഗ്', Icons.water_damage_rounded),
      ('Pest Control', 'കീട നിയന്ത്രണം', Icons.pest_control_rounded),
      ('Sofa & Carpet Cleaning', 'സോഫ / കാർപെറ്റ് ക്ലീനിംഗ്', Icons.weekend_rounded),
      ('Bathroom Cleaning', 'ബാത്ത്റൂം ക്ലീനിംഗ്', Icons.bathtub_rounded),
      ('Kitchen Cleaning', 'അടുക്കള ക്ലീനിംഗ്', Icons.kitchen_rounded),
      ('Window & Glass Cleaning', 'ജനൽ / ഗ്ലാസ് ക്ലീനിംഗ്', Icons.window_rounded),
      ('Septic Tank Cleaning', 'സെപ്റ്റിക് ടാങ്ക് ക്ലീനിംഗ്', Icons.recycling_rounded),
      ('Laundry & Ironing', 'അലക്ക് & ഇസ്തിരി', Icons.local_laundry_service_rounded),
    ]),
    _g('vehicle', 'Vehicle Services', 'വാഹന സേവനങ്ങൾ', Icons.directions_car_filled_rounded,
        const Color(0xFF1565C0), [
      ('Driver', 'ഡ്രൈവർ', Icons.directions_car),
      ('Car Mechanic', 'കാർ മെക്കാനിക്', Icons.car_repair_rounded),
      ('Bike Mechanic', 'ബൈക്ക് മെക്കാനിക്', Icons.two_wheeler_rounded),
      ('Puncture Repair', 'പഞ്ചർ റിപ്പയർ', Icons.tire_repair_rounded),
      ('Car Wash', 'കാർ വാഷ്', Icons.local_car_wash_rounded),
      ('Auto Electrician', 'ഓട്ടോ ഇലക്ട്രീഷ്യൻ', Icons.electric_car_rounded),
      ('Denting & Painting', 'ഡെന്റിംഗ് & പെയിന്റിംഗ്', Icons.format_paint),
      ('Auto Rickshaw Driver', 'ഓട്ടോറിക്ഷ ഡ്രൈവർ', Icons.electric_rickshaw_rounded),
      ('Heavy Vehicle Driver', 'ഹെവി വാഹന ഡ്രൈവർ', Icons.local_shipping_rounded),
      ('Towing & Breakdown Help', 'ടോവിംഗ് / ബ്രേക്ക്ഡൗൺ സഹായം', Icons.fire_truck_rounded),
    ]),
    _g('garden', 'Garden & Outdoor', 'പൂന്തോട്ടം & പുറംജോലി', Icons.yard_rounded,
        const Color(0xFF558B2F), [
      ('Gardener', 'തോട്ടക്കാരൻ', Icons.yard),
      ('Coconut Climber', 'തെങ്ങുകയറ്റക്കാരൻ', Icons.park_rounded),
      ('Tree Cutter', 'മരം വെട്ടുകാരൻ', Icons.forest_rounded),
      ('Grass Cutter', 'പുല്ല് വെട്ടുകാരൻ', Icons.grass_rounded),
      ('Landscaping', 'ലാൻഡ്സ്കേപ്പിംഗ്', Icons.landscape_rounded),
      ('Well Digger', 'കിണർ കുഴിക്കുന്നയാൾ', Icons.hardware_rounded),
      ('Farm Worker', 'കൃഷി ജോലിക്കാരൻ', Icons.agriculture_rounded),
      ('Rubber Tapper', 'റബ്ബർ ടാപ്പർ', Icons.eco_rounded),
      ('Fence & Gate Worker', 'വേലി / ഗേറ്റ് ജോലിക്കാരൻ', Icons.fence_rounded),
    ]),
    _g('personal', 'Personal & Home Care', 'വ്യക്തിഗത & വീട്ടുസേവനം',
        Icons.face_retouching_natural_rounded, const Color(0xFFD81B60), [
      ('Cook', 'പാചകക്കാരൻ', Icons.restaurant),
      ('Babysitter', 'ബേബിസിറ്റർ', Icons.child_care_rounded),
      ('House Maid', 'വീട്ടുജോലിക്കാരി', Icons.house_rounded),
      ('Beautician', 'ബ്യൂട്ടീഷ്യൻ', Icons.spa_rounded),
      ('Barber & Hair Stylist', 'ബാർബർ / ഹെയർ സ്റ്റൈലിസ്റ്റ്', Icons.content_cut_rounded),
      ('Mehendi Artist', 'മെഹന്ദി ആർട്ടിസ്റ്റ്', Icons.brush_rounded),
      ('Pet Care', 'വളർത്തുമൃഗ പരിചരണം', Icons.pets_rounded),
      ('Personal Driver', 'പേഴ്സണൽ ഡ്രൈവർ', Icons.drive_eta_rounded),
    ]),
    _g('health', 'Health & Elder Care', 'ആരോഗ്യം & വയോജന പരിചരണം',
        Icons.medical_services_rounded, const Color(0xFFE53935), [
      ('Caretaker', 'കെയർടേക്കർ', Icons.volunteer_activism_rounded),
      ('Home Nurse', 'ഹോം നഴ്സ്', Icons.local_hospital_rounded),
      ('Elder Care Attendant', 'വയോജന പരിചാരകൻ', Icons.elderly_rounded),
      ('Physiotherapist', 'ഫിസിയോതെറാപ്പിസ്റ്റ്', Icons.accessibility_new_rounded),
      ('Ayurveda Massage Therapist', 'ആയുർവേദ മസാജ് തെറാപ്പിസ്റ്റ്', Icons.self_improvement_rounded),
      ('Yoga Trainer', 'യോഗ പരിശീലകൻ', Icons.self_improvement),
      ('Ambulance Driver', 'ആംബുലൻസ് ഡ്രൈവർ', Icons.emergency_rounded),
    ]),
    _g('construction', 'Construction & Labour', 'നിർമ്മാണം & തൊഴിൽ', Icons.construction_rounded,
        const Color(0xFFEF6C00), [
      ('Mason', 'മേസ്തിരി', Icons.foundation),
      ('Mason Helper', 'മേസ്തിരി സഹായി', Icons.engineering_rounded),
      ('Plastering Worker', 'പ്ലാസ്റ്ററിംഗ് ജോലിക്കാരൻ', Icons.format_color_fill_rounded),
      ('Steel Fixer / Bar Bender', 'കമ്പി പണിക്കാരൻ', Icons.linear_scale_rounded),
      ('Shuttering Carpenter', 'ഷട്ടറിംഗ് ആശാരി', Icons.carpenter),
      ('Roofing Worker', 'മേൽക്കൂര ജോലിക്കാരൻ', Icons.roofing_rounded),
      ('Interlock & Paving Worker', 'ഇന്റർലോക്ക് ജോലിക്കാരൻ', Icons.grid_on_rounded),
      ('JCB / Earth Mover Operator', 'ജെസിബി / മണ്ണുമാന്തി ഓപ്പറേറ്റർ', Icons.agriculture_rounded),
      ('Civil Contractor', 'സിവിൽ കോൺട്രാക്ടർ', Icons.business_center_rounded),
      ('Site Supervisor', 'സൈറ്റ് സൂപ്പർവൈസർ', Icons.supervisor_account_rounded),
      ('Daily Wage Labourer', 'ദിവസക്കൂലി തൊഴിലാളി', Icons.people_alt_rounded),
    ]),
    _g('repair', 'Appliance & Electronics Repair', 'ഉപകരണ / ഇലക്ട്രോണിക്സ് റിപ്പയർ',
        Icons.devices_other_rounded, const Color(0xFF5E35B1), [
      ('Appliance Repair', 'ഗൃഹോപകരണ റിപ്പയർ', Icons.home_repair_service_rounded),
      ('Mobile Repair', 'മൊബൈൽ റിപ്പയർ', Icons.smartphone_rounded),
      ('Laptop & Computer Repair', 'ലാപ്ടോപ്പ് / കമ്പ്യൂട്ടർ റിപ്പയർ', Icons.laptop_mac_rounded),
      ('TV Repair', 'ടിവി റിപ്പയർ', Icons.tv_rounded),
      ('Washing Machine Repair', 'വാഷിംഗ് മെഷീൻ റിപ്പയർ', Icons.local_laundry_service_rounded),
      ('Refrigerator Repair', 'ഫ്രിഡ്ജ് റിപ്പയർ', Icons.kitchen_rounded),
      ('Wi-Fi & Network Technician', 'വൈഫൈ / നെറ്റ്‌വർക്ക് ടെക്നീഷ്യൻ', Icons.wifi_rounded),
      ('DTH & Dish Technician', 'ഡിഷ് / ഡിടിഎച്ച് ടെക്നീഷ്യൻ', Icons.satellite_alt_rounded),
      ('Watch Repair', 'വാച്ച് റിപ്പയർ', Icons.watch_rounded),
      ('Mixer & Grinder Repair', 'മിക്സി / ഗ്രൈൻഡർ റിപ്പയർ', Icons.blender_rounded),
    ]),
    _g('moving', 'Moving & Delivery', 'ഷിഫ്റ്റിംഗ് & ഡെലിവറി', Icons.local_shipping_rounded,
        const Color(0xFF6D4C41), [
      ('Packers & Movers', 'പാക്കേഴ്സ് & മൂവേഴ്സ്', Icons.inventory_2_rounded),
      ('Loading & Unloading Worker', 'ചുമട്ടുതൊഴിലാളി', Icons.front_loader),
      ('Pickup / Mini Truck Driver', 'പിക്കപ്പ് / മിനി ലോറി ഡ്രൈവർ', Icons.local_shipping_rounded),
      ('Delivery Person', 'ഡെലിവറി ജീവനക്കാരൻ', Icons.delivery_dining_rounded),
      ('Courier Service', 'കൊറിയർ സർവീസ്', Icons.markunread_mailbox_rounded),
    ]),
    _g('events', 'Events & Catering', 'പരിപാടികൾ & കേറ്ററിംഗ്', Icons.celebration_rounded,
        const Color(0xFFFB8C00), [
      ('Catering Service', 'കേറ്ററിംഗ് സർവീസ്', Icons.dinner_dining_rounded),
      ('Sadya / Wedding Cook', 'സദ്യ / കല്യാണ പാചകക്കാരൻ', Icons.restaurant_menu_rounded),
      ('Event Decorator', 'ഡെക്കറേറ്റർ', Icons.celebration_rounded),
      ('Flower Decorator', 'പൂ അലങ്കാരം', Icons.local_florist_rounded),
      ('Photographer', 'ഫോട്ടോഗ്രാഫർ', Icons.photo_camera_rounded),
      ('Videographer', 'വീഡിയോഗ്രാഫർ', Icons.videocam_rounded),
      ('DJ & Sound System', 'ശബ്ദ സംവിധാനം / ഡിജെ', Icons.speaker_rounded),
      ('Tent & Pandal Worker', 'പന്തൽ ജോലിക്കാരൻ', Icons.festival_rounded),
      ('Serving Staff', 'വിളമ്പുകാരൻ', Icons.room_service_rounded),
    ]),
    _g('tailoring', 'Tailoring & Fashion', 'തയ്യൽ & ഫാഷൻ', Icons.checkroom_rounded,
        const Color(0xFF8E24AA), [
      ('Tailor', 'തയ്യൽക്കാരൻ', Icons.checkroom_rounded),
      ('Boutique Designer', 'ബൊട്ടീക് ഡിസൈനർ', Icons.design_services_rounded),
      ('Embroidery Worker', 'എംബ്രോയിഡറി ജോലിക്കാരൻ', Icons.gesture_rounded),
      ('Cobbler', 'ചെരുപ്പ് നന്നാക്കുന്നയാൾ', Icons.hiking_rounded),
      ('Alteration Specialist', 'വസ്ത്ര മാറ്റം വരുത്തൽ', Icons.content_cut_rounded),
    ]),
    _g('education', 'Education & Training', 'വിദ്യാഭ്യാസം & പരിശീലനം', Icons.school_rounded,
        const Color(0xFF0277BD), [
      ('Tutor', 'ട്യൂട്ടർ', Icons.menu_book_rounded),
      ('Music Teacher', 'സംഗീത അധ്യാപകൻ', Icons.music_note_rounded),
      ('Dance Teacher', 'നൃത്ത അധ്യാപകൻ', Icons.nightlife_rounded),
      ('Drawing Teacher', 'ചിത്രരചന അധ്യാപകൻ', Icons.palette_rounded),
      ('Spoken English Trainer', 'സ്പോക്കൺ ഇംഗ്ലീഷ് പരിശീലകൻ', Icons.record_voice_over_rounded),
      ('Computer Trainer', 'കമ്പ്യൂട്ടർ പരിശീലകൻ', Icons.computer_rounded),
      ('Driving Instructor', 'ഡ്രൈവിംഗ് ഇൻസ്ട്രക്ടർ', Icons.directions_car_rounded),
      ('Fitness Trainer', 'ഫിറ്റ്നസ് ട്രെയിനർ', Icons.fitness_center_rounded),
    ]),
    _g('staffing', 'Security & Office Staff', 'സെക്യൂരിറ്റി & ഓഫീസ് ജീവനക്കാർ', Icons.security_rounded,
        const Color(0xFF455A64), [
      ('Security Guard', 'സെക്യൂരിറ്റി ഗാർഡ്', Icons.shield_rounded),
      ('Watchman', 'വാച്ച്മാൻ', Icons.visibility_rounded),
      ('Office Boy / Peon', 'ഓഫീസ് ബോയ് / പ്യൂൺ', Icons.badge_rounded),
      ('Shop Assistant', 'ഷോപ്പ് അസിസ്റ്റന്റ്', Icons.storefront_rounded),
      ('Receptionist', 'റിസപ്ഷനിസ്റ്റ്', Icons.support_agent_rounded),
      ('Data Entry Operator', 'ഡാറ്റാ എൻട്രി ഓപ്പറേറ്റർ', Icons.keyboard_rounded),
    ]),
    _g('crafts', 'Skilled Crafts', 'പരമ്പരാഗത കരകൗശലം', Icons.handyman_rounded,
        const Color(0xFF795548), [
      ('Goldsmith', 'സ്വർണ്ണപ്പണിക്കാരൻ', Icons.diamond_rounded),
      ('Blacksmith', 'കൊല്ലൻ', Icons.hardware_rounded),
      ('Potter', 'കുശവൻ', Icons.emoji_food_beverage_rounded),
      ('Stone Mason / Sculptor', 'ശില്പി / കല്ല് പണിക്കാരൻ', Icons.account_balance_rounded),
      ('Upholstery Worker', 'സോഫ / അപ്ഹോൾസ്റ്ററി ജോലിക്കാരൻ', Icons.weekend_rounded),
      ('Mattress Maker', 'മെത്ത നിർമ്മാതാവ്', Icons.bed_rounded),
      ('Cane & Bamboo Worker', 'ചൂരൽ / മുള പണിക്കാരൻ', Icons.grass_rounded),
    ]),
  ];
}
