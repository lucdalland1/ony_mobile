// ignore: file_names
class EmmettreCartePhysique {
  final int id;
  final String phone;
  final int cardID;
  final String lastName;
  final String firstName;
  final String? password;
  final int? isPwdChanged;
  final String? pin;
  final int? isPinChanged;
  final String cardLast4Digits;
  final String cardExpireAt;
  final String? currency;
  final double? balance;
  final String? lastBalanceDate;
  final String userType;
  final String? email;
  final String? gender;
  final String? address1;
  final String? city;
  final int? country;
  final String? stateRegion;
  final String? postalCode;
  final String? birthDate;
  final int? idType;
  final String? idValue;
  final String? mobilePhoneNumber;
  final String? alternatePhoneNumber;
  final int? subCompany;
  final int? wallet;
  final String? lastRecharge;
  final int? suspended;
  final int? actived;
  final String? createdBy;
  final String? createdAt;
  final String? updatedAt;
  final String? updatedBy;
  final String? codePromo;
  final String? withCodePromo;
  final String? cardIDParrain;
  final String? version;
  final String? cardIDVirtual;
  final String? cardLast4DigitsVirtual;
  final String? cardExpireAtVirtual;
  final String? providerCardIDVirtual;
  final String? compteVStatus;
  final String? pro;
  final int? staff;
  final int? marchandId;
  final String? activePhysique;
  final String? activeVirtuelle;
  final String? createdVirtualAt;
  final String? deletedAt;

  EmmettreCartePhysique({
    required this.id,
    required this.phone,
    required this.cardID,
    required this.lastName,
    required this.firstName,
    this.password,
    this.isPwdChanged,
    this.pin,
    this.isPinChanged,
    required this.cardLast4Digits,
    required this.cardExpireAt,
    this.currency,
    this.balance,
    this.lastBalanceDate,
    required this.userType,
    this.email,
    this.gender,
    this.address1,
    this.city,
    this.country,
    this.stateRegion,
    this.postalCode,
    this.birthDate,
    this.idType,
    this.idValue,
    this.mobilePhoneNumber,
    this.alternatePhoneNumber,
    this.subCompany,
    this.wallet,
    this.lastRecharge,
    this.suspended,
    this.actived,
    this.createdBy,
    this.createdAt,
    this.updatedAt,
    this.updatedBy,
    this.codePromo,
    this.withCodePromo,
    this.cardIDParrain,
    this.version,
    this.cardIDVirtual,
    this.cardLast4DigitsVirtual,
    this.cardExpireAtVirtual,
    this.providerCardIDVirtual,
    this.compteVStatus,
    this.pro,
    this.staff,
    this.marchandId,
    this.activePhysique,
    this.activeVirtuelle,
    this.createdVirtualAt,
    this.deletedAt,
  });

  factory EmmettreCartePhysique.fromJson(Map<String, dynamic> json) {
    return EmmettreCartePhysique(
      id: json['id'] ?? 0,
      phone: json['phone']?.toString() ?? '',
      cardID: json['cardID'] ?? 0,
      lastName: json['lastName'] ?? '',
      firstName: json['firstName'] ?? '',
      password: json['password'],
      isPwdChanged: json['isPwdChanged'],
      pin: json['pin'],
      isPinChanged: json['isPinChanged'],
      cardLast4Digits: json['cardLast4Digits'] ?? '',
      cardExpireAt: json['cardExpireAt'] ?? '',
      currency: json['currency'],
      balance: (json['balance'] != null)
          ? double.tryParse(json['balance'].toString())
          : null,
      lastBalanceDate: json['last_balance_date'],
      userType: json['userType'] ?? '',
      email: json['email'],
      gender: json['gender'],
      address1: json['address1'],
      city: json['city'],
      country: json['country'],
      stateRegion: json['stateRegion'],
      postalCode: json['postalCode'],
      birthDate: json['birthDate'],
      idType: json['idType'],
      idValue: json['idValue'],
      mobilePhoneNumber: json['mobilePhoneNumber'],
      alternatePhoneNumber: json['alternatePhoneNumber'],
      subCompany: json['subCompany'],
      wallet: json['wallet'],
      lastRecharge: json['last_recharge'],
      suspended: json['suspended'],
      actived: json['actived'],
      createdBy: json['created_by'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
      updatedBy: json['updated_by'],
      codePromo: json['codePromo'],
      withCodePromo: json['withCodePromo'],
      cardIDParrain: json['cardIDParrain'],
      version: json['version'],
      cardIDVirtual: json['cardIDVirtual'],
      cardLast4DigitsVirtual: json['cardLast4DigitsVirtual'],
      cardExpireAtVirtual: json['cardExpireAtVirtual'],
      providerCardIDVirtual: json['providerCardIDVirtual'],
      compteVStatus: json['CompteVStatus'],
      pro: json['pro'],
      staff: json['staff'],
      marchandId: json['marchand_id'],
      activePhysique: json['activePysique'],
      activeVirtuelle: json['activeVirtuelle'],
      createdVirtualAt: json['created_virtual_at'],
      deletedAt: json['deleted_at'],
    );
  }
}
