class CVData {
  String name = '';
  String title = '';
  String summary = '';
  String email = '';
  String phone = '';
  String linkedin = '';
  String address = '';
  List<String> experience = [];
  List<String> education = [];
  List<String> skills = [];
  List<String> projects = [];
  List<String> languages = [];
  List<String> certifications = [];

  CVData({
    this.name = '',
    this.title = '',
    this.summary = '',
    this.email = '',
    this.phone = '',
    this.linkedin = '',
    this.address = '',
    this.experience = const [],
    this.education = const [],
    this.skills = const [],
    this.projects = const [],
    this.languages = const [],
    this.certifications = const [],
  });
}
