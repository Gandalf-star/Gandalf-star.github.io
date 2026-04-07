class AdminConfig {
  // Lista de correos autorizados como administradores
  static const List<String> admins = [
    'admin@clickv2.com',
    'ceosamuel@clickexpress.com',
  ];

  static bool esAdmin(String? email) {
    if (email == null) return false;
    return admins.contains(email.toLowerCase());
  }
}
