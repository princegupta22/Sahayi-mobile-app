import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'app_language.dart';

export 'categories.dart';

/// Central translation table for every screen from the dashboard onward.
/// Auth/splash screens show both languages stacked instead of using this.
class S {
  S._();

  static const Map<String, Map<AppLanguage, String>> _table = {
    // Dashboard / shell
    'home': {AppLanguage.english: 'Home', AppLanguage.malayalam: 'ഹോം'},
    'find_worker_tab': {
      AppLanguage.english: 'Find Worker',
      AppLanguage.malayalam: 'തൊഴിലാളി',
    },
    'messages': {
      AppLanguage.english: 'Messages',
      AppLanguage.malayalam: 'സന്ദേശങ്ങൾ',
    },
    'profile': {
      AppLanguage.english: 'Profile',
      AppLanguage.malayalam: 'പ്രൊഫൈൽ',
    },
    'search_categories': {
      AppLanguage.english: 'Search services, e.g. Electrician',
      AppLanguage.malayalam: 'സേവനങ്ങൾ തിരയുക, ഉദാ. ഇലക്ട്രീഷ്യൻ',
    },
    'enter_city': {
      AppLanguage.english: 'City, e.g. Kochi',
      AppLanguage.malayalam: 'നഗരം, ഉദാ. കൊച്ചി',
    },
    'search': {
      AppLanguage.english: 'Search',
      AppLanguage.malayalam: 'തിരയുക',
    },
    'all_services': {
      AppLanguage.english: 'All Services',
      AppLanguage.malayalam: 'എല്ലാ സേവനങ്ങളും',
    },
    'worker_word': {
      AppLanguage.english: 'worker',
      AppLanguage.malayalam: 'തൊഴിലാളി',
    },
    'workers_word': {
      AppLanguage.english: 'workers',
      AppLanguage.malayalam: 'തൊഴിലാളികൾ',
    },
    'view_all_workers': {
      AppLanguage.english: 'View all workers',
      AppLanguage.malayalam: 'എല്ലാ തൊഴിലാളികളെയും കാണുക',
    },
    'no_services_match': {
      AppLanguage.english: 'No matching service found',
      AppLanguage.malayalam: 'യോജിക്കുന്ന സേവനം കണ്ടെത്തിയില്ല',
    },
    'choose_service': {
      AppLanguage.english: 'Choose a service',
      AppLanguage.malayalam: 'ഒരു സേവനം തിരഞ്ഞെടുക്കുക',
    },
    'close': {AppLanguage.english: 'Close', AppLanguage.malayalam: 'അടയ്ക്കുക'},
    'greeting': {
      AppLanguage.english: 'Welcome back',
      AppLanguage.malayalam: 'തിരികെ സ്വാഗതം',
    },
    'find_worker_title': {
      AppLanguage.english: 'Find Worker',
      AppLanguage.malayalam: 'തൊഴിലാളിയെ കണ്ടെത്തുക',
    },
    'find_worker_desc': {
      AppLanguage.english: 'Search skilled workers near your location',
      AppLanguage.malayalam:
          'നിങ്ങളുടെ സ്ഥലത്തിന് സമീപമുള്ള തൊഴിലാളികളെ തിരയുക',
    },

    // Find Work form
    'add_your_details': {
      AppLanguage.english: 'Add Your Work Details',
      AppLanguage.malayalam: 'നിങ്ങളുടെ ജോലി വിവരങ്ങൾ ചേർക്കുക',
    },
    'profile_photo': {
      AppLanguage.english: 'Profile Photo',
      AppLanguage.malayalam: 'പ്രൊഫൈൽ ഫോട്ടോ',
    },
    'tap_to_upload': {
      AppLanguage.english: 'Tap to upload',
      AppLanguage.malayalam: 'അപ്‌ലോഡ് ചെയ്യാൻ ടാപ്പ് ചെയ്യുക',
    },
    'full_name': {
      AppLanguage.english: 'Full Name',
      AppLanguage.malayalam: 'മുഴുവൻ പേര്',
    },
    'work_category': {
      AppLanguage.english: 'What kind of work do you do?',
      AppLanguage.malayalam: 'നിങ്ങൾ ഏത് തരം ജോലിയാണ് ചെയ്യുന്നത്?',
    },
    'experience_years': {
      AppLanguage.english: 'Years of Experience',
      AppLanguage.malayalam: 'പരിചയമുള്ള വർഷങ്ങൾ',
    },
    'about_you': {
      AppLanguage.english: 'About You (optional)',
      AppLanguage.malayalam: 'നിങ്ങളെക്കുറിച്ച് (ഓപ്ഷണൽ)',
    },
    'about_hint': {
      AppLanguage.english: 'Tell customers about your work…',
      AppLanguage.malayalam: 'നിങ്ങളുടെ ജോലിയെക്കുറിച്ച് ഉപഭോക്താക്കളോട് പറയുക…',
    },
    'work_photos': {
      AppLanguage.english: 'Photos of Your Work (2–3)',
      AppLanguage.malayalam: 'നിങ്ങളുടെ ജോലിയുടെ ഫോട്ടോകൾ (2–3)',
    },
    'add_photo': {
      AppLanguage.english: 'Add Photo',
      AppLanguage.malayalam: 'ഫോട്ടോ ചേർക്കുക',
    },
    'city': {AppLanguage.english: 'City', AppLanguage.malayalam: 'നഗരം'},
    'country': {
      AppLanguage.english: 'Country',
      AppLanguage.malayalam: 'രാജ്യം',
    },
    'phone_optional': {
      AppLanguage.english: 'Contact Number',
      AppLanguage.malayalam: 'ബന്ധപ്പെടേണ്ട നമ്പർ',
    },
    'submit_listing': {
      AppLanguage.english: 'Submit My Listing',
      AppLanguage.malayalam: 'എന്റെ ലിസ്റ്റിംഗ് സമർപ്പിക്കുക',
    },
    'listing_success': {
      AppLanguage.english: 'Your profile is now live for customers to find!',
      AppLanguage.malayalam:
          'നിങ്ങളുടെ പ്രൊഫൈൽ ഇപ്പോൾ ഉപഭോക്താക്കൾക്ക് കണ്ടെത്താൻ ലഭ്യമാണ്!',
    },
    'required_field': {
      AppLanguage.english: 'This field is required',
      AppLanguage.malayalam: 'ഈ ഫീൽഡ് നിർബന്ധമാണ്',
    },

    // Find Worker search
    'search_hint': {
      AppLanguage.english: 'Search e.g. Plumber, Electrician…',
      AppLanguage.malayalam: 'തിരയുക ഉദാ. പ്ലംബർ, ഇലക്ട്രീഷ്യൻ…',
    },
    'select_category': {
      AppLanguage.english: 'Select Category',
      AppLanguage.malayalam: 'വിഭാഗം തിരഞ്ഞെടുക്കുക',
    },
    'all': {AppLanguage.english: 'All', AppLanguage.malayalam: 'എല്ലാം'},
    'location': {
      AppLanguage.english: 'Location',
      AppLanguage.malayalam: 'സ്ഥലം',
    },
    'filter_by_location': {
      AppLanguage.english: 'Filter by city or country',
      AppLanguage.malayalam: 'നഗരം അല്ലെങ്കിൽ രാജ്യം അനുസരിച്ച് ഫിൽട്ടർ ചെയ്യുക',
    },
    'workers_found': {
      AppLanguage.english: 'workers found',
      AppLanguage.malayalam: 'തൊഴിലാളികളെ കണ്ടെത്തി',
    },
    'no_workers_found': {
      AppLanguage.english: 'No workers found',
      AppLanguage.malayalam: 'തൊഴിലാളികളെ കണ്ടെത്തിയില്ല',
    },
    'try_different_search': {
      AppLanguage.english: 'Try a different category or location',
      AppLanguage.malayalam: 'മറ്റൊരു വിഭാഗം അല്ലെങ്കിൽ സ്ഥലം പരീക്ഷിക്കുക',
    },
    'clear_filters': {
      AppLanguage.english: 'Clear Filters',
      AppLanguage.malayalam: 'ഫിൽട്ടറുകൾ മായ്ക്കുക',
    },

    // Worker detail
    'view_profile': {
      AppLanguage.english: 'View Profile',
      AppLanguage.malayalam: 'പ്രൊഫൈൽ കാണുക',
    },
    'call_now': {
      AppLanguage.english: 'Call Now',
      AppLanguage.malayalam: 'ഇപ്പോൾ വിളിക്കുക',
    },
    'send_message': {
      AppLanguage.english: 'Send Message',
      AppLanguage.malayalam: 'സന്ദേശം അയയ്ക്കുക',
    },
    'about': {
      AppLanguage.english: 'About',
      AppLanguage.malayalam: 'വിവരണം',
    },
    'work_gallery': {
      AppLanguage.english: 'Work Gallery',
      AppLanguage.malayalam: 'ജോലി ഗാലറി',
    },
    'years_exp': {
      AppLanguage.english: 'yrs experience',
      AppLanguage.malayalam: 'വർഷത്തെ പരിചയം',
    },

    // Profile tab
    'my_profile': {
      AppLanguage.english: 'My Profile',
      AppLanguage.malayalam: 'എന്റെ പ്രൊഫൈൽ',
    },
    'my_listing': {
      AppLanguage.english: 'My Work Listing',
      AppLanguage.malayalam: 'എന്റെ ജോലി ലിസ്റ്റിംഗ്',
    },
    'settings': {
      AppLanguage.english: 'Settings',
      AppLanguage.malayalam: 'ക്രമീകരണങ്ങൾ',
    },
    'language': {
      AppLanguage.english: 'Language',
      AppLanguage.malayalam: 'ഭാഷ',
    },
    'logout': {
      AppLanguage.english: 'Log Out',
      AppLanguage.malayalam: 'ലോഗ് ഔട്ട്',
    },
    'no_listing_yet': {
      AppLanguage.english: "You haven't listed your work yet",
      AppLanguage.malayalam: 'നിങ്ങൾ ഇതുവരെ നിങ്ങളുടെ ജോലി ലിസ്റ്റ് ചെയ്തിട്ടില്ല',
    },
    'create_listing': {
      AppLanguage.english: 'Create Worker Profile',
      AppLanguage.malayalam: 'തൊഴിലാളി പ്രൊഫൈൽ സൃഷ്ടിക്കുക',
    },
    'coming_soon': {
      AppLanguage.english: 'Coming soon',
      AppLanguage.malayalam: 'ഉടൻ വരുന്നു',
    },
    'type_a_message': {
      AppLanguage.english: 'Type a message…',
      AppLanguage.malayalam: 'ഒരു സന്ദേശം ടൈപ്പ് ചെയ്യുക…',
    },
    'log_in': {
      AppLanguage.english: 'Log In',
      AppLanguage.malayalam: 'പ്രവേശിക്കുക',
    },
    'welcome_back_login': {
      AppLanguage.english: 'Welcome back! Log in to continue.',
      AppLanguage.malayalam: 'സ്വാഗതം! തുടരാൻ പ്രവേശിക്കുക.',
    },
    'email_address': {
      AppLanguage.english: 'Email',
      AppLanguage.malayalam: 'ഇമെയിൽ',
    },
    'email_hint': {
      AppLanguage.english: 'you@example.com',
      AppLanguage.malayalam: 'you@example.com',
    },
    'phone_hint': {
      AppLanguage.english: '10-digit mobile number',
      AppLanguage.malayalam: '10 അക്ക മൊബൈൽ നമ്പർ',
    },
    'password': {
      AppLanguage.english: 'Password',
      AppLanguage.malayalam: 'പാസ്‌വേഡ്',
    },
    'confirm_password': {
      AppLanguage.english: 'Confirm Password',
      AppLanguage.malayalam: 'പാസ്‌വേഡ് സ്ഥിരീകരിക്കുക',
    },
    'no_account': {
      AppLanguage.english: 'Don\'t have an account?',
      AppLanguage.malayalam: 'അക്കൗണ്ട് ഇല്ലേ?',
    },
    'sign_up': {
      AppLanguage.english: 'Sign Up',
      AppLanguage.malayalam: 'രജിസ്റ്റർ ചെയ്യുക',
    },
    'have_account': {
      AppLanguage.english: 'Already have an account?',
      AppLanguage.malayalam: 'ഇതിനകം അക്കൗണ്ട് ഉണ്ടോ?',
    },
    'create_account': {
      AppLanguage.english: 'Create Account',
      AppLanguage.malayalam: 'അക്കൗണ്ട് സൃഷ്ടിക്കുക',
    },
    'signup_subtitle': {
      AppLanguage.english: 'Join Sahayi to find work or trusted help nearby.',
      AppLanguage.malayalam: 'ജോലി കണ്ടെത്താനോ വിശ്വസനീയമായ സഹായം കണ്ടെത്താനോ സഹായിയിൽ ചേരുക.',
    },
    'consent_terms': {
      AppLanguage.english:
          "This app is provided on an 'as is' basis without warranties of any kind. We are not liable for any losses resulting from your use of the app or any transactions conducted outside the official platform.",
      AppLanguage.malayalam:
          "ഈ ആപ്പ് യാതൊരു വിധ വാറന്റിയും ഇല്ലാതെ 'ഉള്ളതുപോലെ' എന്ന അടിസ്ഥാനത്തിലാണ് നൽകുന്നത്. ആപ്പിന്റെ ഉപയോഗത്തിൽ നിന്നോ ഔദ്യോഗിക പ്ലാറ്റ്‌ഫോമിന് പുറത്ത് നടത്തുന്ന ഇടപാടുകളിൽ നിന്നോ ഉണ്ടാകുന്ന നഷ്ടങ്ങൾക്ക് ഞങ്ങൾ ഉത്തരവാദികളല്ല.",
    },
    'consent_no_bypass': {
      AppLanguage.english:
          'Users and service providers are strictly prohibited from exchanging direct contact information to bypass the app. All communications and bookings must occur through the official platform. Bypassing the app violates our policy and will lead to immediate account suspension.',
      AppLanguage.malayalam:
          'ആപ്പ് ഒഴിവാക്കുന്നതിനായി ഉപയോക്താക്കളും സേവന ദാതാക്കളും നേരിട്ടുള്ള ബന്ധപ്പെടൽ വിവരങ്ങൾ കൈമാറുന്നത് കർശനമായി നിരോധിച്ചിരിക്കുന്നു. എല്ലാ ആശയവിനിമയങ്ങളും ബുക്കിംഗുകളും ഔദ്യോഗിക പ്ലാറ്റ്‌ഫോമിലൂടെ മാത്രമേ നടക്കാവൂ. ആപ്പ് ഒഴിവാക്കുന്നത് ഞങ്ങളുടെ നയത്തിന്റെ ലംഘനമാണ്, ഇത് ഉടനടി അക്കൗണ്ട് സസ്പെൻഷനിലേക്ക് നയിക്കും.',
    },
    'err_consent': {
      AppLanguage.english: 'Please tick to agree before continuing',
      AppLanguage.malayalam: 'തുടരുന്നതിന് മുമ്പ് ടിക്ക് ചെയ്ത് സമ്മതിക്കുക',
    },
    'name_hint': {
      AppLanguage.english: 'e.g. Anjali Nair',
      AppLanguage.malayalam: 'ഉദാ: അഞ്ജലി നായർ',
    },
    'err_name': {
      AppLanguage.english: 'Please enter your name',
      AppLanguage.malayalam: 'നിങ്ങളുടെ പേര് നൽകുക',
    },
    'err_email': {
      AppLanguage.english: 'Enter a valid email address',
      AppLanguage.malayalam: 'സാധുവായ ഇമെയിൽ വിലാസം നൽകുക',
    },
    'err_phone': {
      AppLanguage.english: 'Enter a valid 10-digit number',
      AppLanguage.malayalam: 'സാധുവായ 10 അക്ക നമ്പർ നൽകുക',
    },
    'err_password': {
      AppLanguage.english: 'Password must be at least 6 characters',
      AppLanguage.malayalam: 'പാസ്‌വേഡ് കുറഞ്ഞത് 6 അക്ഷരം വേണം',
    },
    'err_match': {
      AppLanguage.english: 'Passwords don\'t match',
      AppLanguage.malayalam: 'പാസ്‌വേഡുകൾ പൊരുത്തപ്പെടുന്നില്ല',
    },
    'tagline': {
      AppLanguage.english: 'Reliable service, now at your home too.',
      AppLanguage.malayalam: 'വിശ്വസനീയ സേവനം, ഇനി നിങ്ങളുടെ വീട്ടിലും.',
    },
    'unlock_contact': {
      AppLanguage.english: 'Unlock Contact',
      AppLanguage.malayalam: 'ബന്ധപ്പെടൽ അൺലോക്ക് ചെയ്യുക',
    },
    'unlock_subtitle': {
      AppLanguage.english: 'Pay once to message and call any worker on Sahayi.',
      AppLanguage.malayalam: 'സഹായിയിലെ ഏത് തൊഴിലാളിക്കും സന്ദേശം അയയ്ക്കാനും വിളിക്കാനും ഒരിക്കൽ മാത്രം പണമടയ്ക്കുക.',
    },
    'unlock_fee': {
      AppLanguage.english: 'Contact Unlock Fee',
      AppLanguage.malayalam: 'ബന്ധപ്പെടൽ അൺലോക്ക് ഫീസ്',
    },
    'listing_fee_title': {
      AppLanguage.english: 'Publish Your Profile',
      AppLanguage.malayalam: 'നിങ്ങളുടെ പ്രൊഫൈൽ പ്രസിദ്ധീകരിക്കുക',
    },
    'listing_fee_subtitle': {
      AppLanguage.english: 'A small one-time fee keeps worker profiles genuine and spam-free.',
      AppLanguage.malayalam: 'തൊഴിലാളി പ്രൊഫൈലുകൾ യഥാർത്ഥവും സ്പാം രഹിതവുമായി നിലനിർത്താൻ ഒരു ചെറിയ ഒറ്റത്തവണ ഫീസ്.',
    },
    'listing_fee': {
      AppLanguage.english: 'Worker Profile Fee',
      AppLanguage.malayalam: 'തൊഴിലാളി പ്രൊഫൈൽ ഫീസ്',
    },
    'perk_listed': {
      AppLanguage.english: 'Your profile shown to customers',
      AppLanguage.malayalam: 'നിങ്ങളുടെ പ്രൊഫൈൽ ഉപഭോക്താക്കൾക്ക് കാണാം',
    },
    'perk_get_contacted': {
      AppLanguage.english: 'Customers can message and call you',
      AppLanguage.malayalam: 'ഉപഭോക്താക്കൾക്ക് നിങ്ങൾക്ക് സന്ദേശം അയയ്ക്കാനും വിളിക്കാനും കഴിയും',
    },
    'perk_edit_anytime': {
      AppLanguage.english: 'Edit your profile any time',
      AppLanguage.malayalam: 'എപ്പോൾ വേണമെങ്കിലും പ്രൊഫൈൽ എഡിറ്റ് ചെയ്യാം',
    },
    'available': {
      AppLanguage.english: 'Available',
      AppLanguage.malayalam: 'ലഭ്യമാണ്',
    },
    'booked': {
      AppLanguage.english: 'Booked',
      AppLanguage.malayalam: 'ബുക്ക് ചെയ്തു',
    },
    'availability': {
      AppLanguage.english: 'Availability',
      AppLanguage.malayalam: 'ലഭ്യത',
    },
    'now_available': {
      AppLanguage.english: 'Customers now see you as Available',
      AppLanguage.malayalam: 'ഉപഭോക്താക്കൾ ഇപ്പോൾ നിങ്ങളെ "ലഭ്യമാണ്" എന്ന് കാണും',
    },
    'now_booked': {
      AppLanguage.english: 'Customers now see you as Booked',
      AppLanguage.malayalam: 'ഉപഭോക്താക്കൾ ഇപ്പോൾ നിങ്ങളെ "ബുക്ക് ചെയ്തു" എന്ന് കാണും',
    },
    'availability_hint': {
      AppLanguage.english: 'Turn off when you are booked. Customers will see "Booked".',
      AppLanguage.malayalam: 'ബുക്ക് ആയിരിക്കുമ്പോൾ ഓഫ് ചെയ്യുക. ഉപഭോക്താക്കൾ "ബുക്ക് ചെയ്തു" എന്ന് കാണും.',
    },
    'incl_taxes': {
      AppLanguage.english: '(Inclusive of all Taxes)',
      AppLanguage.malayalam: '(എല്ലാ നികുതികളും ഉൾപ്പെടെ)',
    },
    'one_time': {
      AppLanguage.english: 'One-time charge, no renewals',
      AppLanguage.malayalam: 'ഒറ്റത്തവണ ചാർജ്, പുതുക്കൽ ഇല്ല',
    },
    'perk_message': {
      AppLanguage.english: 'Message any worker',
      AppLanguage.malayalam: 'ഏത് തൊഴിലാളിക്കും സന്ദേശം അയയ്ക്കാം',
    },
    'perk_call': {
      AppLanguage.english: 'Call any worker',
      AppLanguage.malayalam: 'ഏത് തൊഴിലാളിയെയും വിളിക്കാം',
    },
    'perk_all_workers': {
      AppLanguage.english: 'Works for every worker on Sahayi',
      AppLanguage.malayalam: 'സഹായിയിലെ എല്ലാ തൊഴിലാളികൾക്കും ബാധകം',
    },
    'pay_now': {
      AppLanguage.english: 'Pay Now',
      AppLanguage.malayalam: 'ഇപ്പോൾ അടയ്ക്കുക',
    },
    'payment_success': {
      AppLanguage.english: 'Payment Successful',
      AppLanguage.malayalam: 'പേയ്‌മെന്റ് വിജയകരം',
    },
    'verified': {
      AppLanguage.english: 'Verified',
      AppLanguage.malayalam: 'സ്ഥിരീകരിച്ചു',
    },
    'rating_label': {
      AppLanguage.english: 'Rating',
      AppLanguage.malayalam: 'റേറ്റിംഗ്',
    },
    'experience_label': {
      AppLanguage.english: 'Experience',
      AppLanguage.malayalam: 'പരിചയം',
    },
    'years_short': {
      AppLanguage.english: 'Years',
      AppLanguage.malayalam: 'വർഷം',
    },
    'err_invalid_login': {
      AppLanguage.english: 'Wrong email or password',
      AppLanguage.malayalam: 'ഇമെയിലോ പാസ്‌വേഡോ തെറ്റാണ്',
    },
    'err_phone_taken': {
      AppLanguage.english: 'This email is already registered. Please log in.',
      AppLanguage.malayalam: 'ഈ ഇമെയിൽ ഇതിനകം രജിസ്റ്റർ ചെയ്തിട്ടുണ്ട്. ദയവായി പ്രവേശിക്കുക.',
    },
    'err_network': {
      AppLanguage.english: 'No internet connection. Please try again.',
      AppLanguage.malayalam: 'ഇന്റർനെറ്റ് ഇല്ല. വീണ്ടും ശ്രമിക്കുക.',
    },
    'err_rate_limit': {
      AppLanguage.english: 'Too many attempts. Please wait a minute.',
      AppLanguage.malayalam: 'ഒരുപാട് ശ്രമങ്ങൾ. ഒരു മിനിറ്റ് കാത്തിരിക്കുക.',
    },
    'err_payment': {
      AppLanguage.english: 'Payment could not be completed. If money was deducted, it will unlock shortly.',
      AppLanguage.malayalam: 'പേയ്‌മെന്റ് പൂർത്തിയായില്ല. പണം പോയെങ്കിൽ ഉടൻ അൺലോക്ക് ആകും.',
    },
    'err_generic': {
      AppLanguage.english: 'Something went wrong. Please try again.',
      AppLanguage.malayalam: 'എന്തോ പിഴവ് സംഭവിച്ചു. വീണ്ടും ശ്രമിക്കുക.',
    },
    'err_setup_confirm': {
      AppLanguage.english: 'Server setup: turn OFF "Confirm email" in Supabase Auth settings.',
      AppLanguage.malayalam: 'സെർവർ സെറ്റപ്പ്: Supabase Auth-ൽ "Confirm email" ഓഫ് ചെയ്യുക.',
    },
    'retry': {
      AppLanguage.english: 'Retry',
      AppLanguage.malayalam: 'വീണ്ടും ശ്രമിക്കുക',
    },
    'no_phone': {
      AppLanguage.english: 'This worker has not shared a phone number. Send a message instead.',
      AppLanguage.malayalam: 'ഈ തൊഴിലാളി ഫോൺ നമ്പർ നൽകിയിട്ടില്ല. സന്ദേശം അയയ്ക്കുക.',
    },
    'cant_message_self': {
      AppLanguage.english: 'This is your own listing.',
      AppLanguage.malayalam: 'ഇത് നിങ്ങളുടെ സ്വന്തം ലിസ്റ്റിംഗ് ആണ്.',
    },
    'cant_open_dialer': {
      AppLanguage.english: 'Could not open the phone dialer.',
      AppLanguage.malayalam: 'ഫോൺ ഡയലർ തുറക്കാനായില്ല.',
    },
    'photo_denied': {
      AppLanguage.english: 'Photo access is off. Enable it in Settings to add photos.',
      AppLanguage.malayalam: 'ഫോട്ടോ ആക്‌സസ് ഓഫ് ആണ്. ഫോട്ടോ ചേർക്കാൻ സെറ്റിംഗ്സിൽ ഓൺ ചെയ്യുക.',
    },
    'send_failed': {
      AppLanguage.english: 'Message not sent. Try again.',
      AppLanguage.malayalam: 'സന്ദേശം അയച്ചില്ല. വീണ്ടും ശ്രമിക്കുക.',
    },
    'new_label': {
      AppLanguage.english: 'New',
      AppLanguage.malayalam: 'പുതിയത്',
    },
    'update_listing': {
      AppLanguage.english: 'Update Listing',
      AppLanguage.malayalam: 'ലിസ്റ്റിംഗ് പുതുക്കുക',
    },
    'edit_listing': {
      AppLanguage.english: 'Edit Listing',
      AppLanguage.malayalam: 'ലിസ്റ്റിംഗ് എഡിറ്റ് ചെയ്യുക',
    },
    'listing_updated': {
      AppLanguage.english: 'Your listing was updated!',
      AppLanguage.malayalam: 'നിങ്ങളുടെ ലിസ്റ്റിംഗ് പുതുക്കി!',
    },
    'no_conversations': {
      AppLanguage.english: 'No conversations yet',
      AppLanguage.malayalam: 'ഇതുവരെ സംഭാഷണങ്ങൾ ഇല്ല',
    },
    'no_conversations_hint': {
      AppLanguage.english: 'Message a worker to start chatting.',
      AppLanguage.malayalam: 'ചാറ്റ് തുടങ്ങാൻ ഒരു തൊഴിലാളിക്ക് സന്ദേശം അയയ്ക്കുക.',
    },
    'no_workers_yet': {
      AppLanguage.english: 'No workers listed yet. Be the first!',
      AppLanguage.malayalam: 'ഇതുവരെ തൊഴിലാളികളെ ലിസ്റ്റ് ചെയ്തിട്ടില്ല. ആദ്യത്തെയാളാകൂ!',
    },
    'sahayi_member': {
      AppLanguage.english: 'Sahayi member',
      AppLanguage.malayalam: 'സഹായി അംഗം',
    },
    'sign_in_required': {
      AppLanguage.english: 'Please log in again.',
      AppLanguage.malayalam: 'ദയവായി വീണ്ടും പ്രവേശിക്കുക.',
    },
    'no_messages_yet': {
      AppLanguage.english: 'No messages yet',
      AppLanguage.malayalam: 'ഇതുവരെ സന്ദേശങ്ങൾ ഇല്ല',
    },
  };

  static String of(BuildContext context, String key) {
    final lang = context.watch<LanguageProvider>().language;
    return _table[key]?[lang] ?? key;
  }

  static String read(BuildContext context, String key) {
    final lang = context.read<LanguageProvider>().language;
    return _table[key]?[lang] ?? key;
  }
}
