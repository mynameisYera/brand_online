import 'package:flutter/material.dart';

class MaterialsWidget extends StatelessWidget {
  final String title;
  final String url;
  const MaterialsWidget({super.key, required this.title, required this.url});

  @override
  Widget build(BuildContext context) {
    final _appearance = _appearanceFrom(title, url);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 100,
          height: 120,
          decoration: BoxDecoration(
              color: _appearance.color, borderRadius: BorderRadius.circular(10)),
          child: Center(
            child: Icon(
              _appearance.icon,
              color: Colors.white,
              size: 50,
            ),
          ),
        ), 
        SizedBox(
          height: 5,
        ),
        Row(
          children: [
            SizedBox(width: 3), 
            Text(title.length > 12 ? title.substring(0, 11) + "..." : title)
          ],
        )
      ],
    );
  }
}

class _MaterialAppearance {
  final Color color;
  final IconData icon;
  const _MaterialAppearance({required this.color, required this.icon});
}

_MaterialAppearance _appearanceFrom(String nameOrTitle, String url) {
  final String lowered = nameOrTitle.trim().toLowerCase();
  final String ext = _extractExtension(url);

  const photoExts = {
    'jpg',
    'jpeg',
    'png',
    'gif',
    'bmp',
    'webp',
    'heic',
    'heif'
  };
  if (lowered == 'фото' || lowered == 'photo' || photoExts.contains(ext)) {
    return const _MaterialAppearance(
      color: Colors.blueAccent,
      icon: Icons.image,
    );
  }

  if (lowered == 'word' || ext == 'doc' || ext == 'docx') {
    return const _MaterialAppearance(
      color: Colors.indigo,
      icon: Icons.description,
    );
  }

  if (lowered == 'pdf' || ext == 'pdf') {
    return const _MaterialAppearance(
      color: Colors.red,
      icon: Icons.picture_as_pdf,
    );
  }

  if (lowered == 'ppt' || lowered == 'pptx' || lowered == 'powerpoint' || ext == 'ppt' || ext == 'pptx') {
    return const _MaterialAppearance(
      color: Colors.orange,
      icon: Icons.slideshow,
    );
  }

  return const _MaterialAppearance(
    color: Colors.grey,
    icon: Icons.insert_drive_file,
  );
}

String _extractExtension(String pathOrUrl) {
  final String withoutQuery = pathOrUrl.split('?').first;
  final segments = withoutQuery.split('/');
  final String lastSegment = segments.isNotEmpty ? segments.last : withoutQuery;
  final parts = lastSegment.split('.');
  if (parts.length < 2) return '';
  return parts.last.toLowerCase();
}