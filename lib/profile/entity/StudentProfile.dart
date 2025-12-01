class StudentProfile {
  final String firstName;
  final String lastName;
  final String username;
  final int strike;
  final int points;
  final int multiplier;
  final int? top;
  final Group? group;
  final Curator? curator;
  final List<Grade> grades;
  final int daysLeft;
  final ContactLinks contactLinks;
  final int permanent_balance;

  StudentProfile({
    required this.firstName,
    required this.lastName,
    required this.username,
    required this.strike,
    required this.points,
    required this.multiplier,
    this.top,
    required this.group,
    required this.curator,
    required this.grades,
    required this.daysLeft,
    required this.contactLinks,
    required this.permanent_balance,
  });

  factory StudentProfile.fromJson(Map<String, dynamic> json) {
    return StudentProfile(
      firstName: json['first_name'],
      lastName: json['last_name'],
      username: json['username'],
      strike: json['strike'] ?? 0,
      points: json['points'] ?? 0,
      top: json['top'] ?? 0,
      multiplier: json['multiplier'] ?? 1,
      group: json['group'] != null ? Group.fromJson(json['group']) : null,
      curator: json['curator'] != null ? Curator.fromJson(json['curator']) : null,
      grades: (json['grades'] as List)
          .map((item) => Grade.fromJson(item))
          .toList(),
      daysLeft: json['days_left'] ?? 0,
      contactLinks: ContactLinks.fromJson(json['contact_links']),
      permanent_balance: json['permanent_balance'] ?? 0,
    );
  }
}

class Group {
  final String name;

  Group({required this.name});

  factory Group.fromJson(Map<String, dynamic> json) {
    return Group(name: json['name'] ?? '-');
  }
}

class Curator {
  final String firstName;
  final String lastName;
  final String username;

  Curator({
    required this.firstName,
    required this.lastName,
    required this.username,
  });

  factory Curator.fromJson(Map<String, dynamic> json) {
    return Curator(
      firstName: json['first_name'],
      lastName: json['last_name'],
      username: json['username'],
    );
  }
}

class Grade {
  final int gradeId;
  final String subject;
  final String gradeName;

  Grade({
    required this.gradeId,
    required this.subject,
    required this.gradeName,
  });

  factory Grade.fromJson(Map<String, dynamic> json) {
    return Grade(
      gradeId: json['grade_id'],
      subject: json['subject'],
      gradeName: json['grade_name'],
    );
  }
}

class ContactLinks {
  final SocialLink instagram;
  final SocialLink whatsapp;
  final SocialLink telegram;

  ContactLinks({
    required this.instagram,
    required this.whatsapp,
    required this.telegram,
  });

  factory ContactLinks.fromJson(Map<String, dynamic> json) {
    return ContactLinks(
      instagram: SocialLink.fromJson(json['instagram']),
      whatsapp: SocialLink.fromJson(json['whatsapp']),
      telegram: SocialLink.fromJson(json['telegram']),
    );
  }
}

class SocialLink {
  final String name;
  final String link;

  SocialLink({required this.name, required this.link});

  factory SocialLink.fromJson(Map<String, dynamic> json) {
    return SocialLink(
      name: json['name'],
      link: json['link'],
    );
  }
}