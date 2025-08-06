class PersonModel {
  final int? id;
  final String? nombre;
  final int? edadEstimada;
  final String? nacionalidad;
  final DateTime fechaHora;
  final String? ubicacionGPS;
  final String descripcion;
  final String? fotoPath;
  final String? audioPath;

  PersonModel({
    this.id,
    this.nombre,
    this.edadEstimada,
    this.nacionalidad,
    required this.fechaHora,
    this.ubicacionGPS,
    required this.descripcion,
    this.fotoPath,
    this.audioPath,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nombre': nombre,
      'edad_estimada': edadEstimada,
      'nacionalidad': nacionalidad,
      'fecha_hora': fechaHora.millisecondsSinceEpoch,
      'ubicacion_gps': ubicacionGPS,
      'descripcion': descripcion,
      'foto_path': fotoPath,
      'audio_path': audioPath,
    };
  }

  factory PersonModel.fromMap(Map<String, dynamic> map) {
    return PersonModel(
      id: map['id'],
      nombre: map['nombre'],
      edadEstimada: map['edad_estimada'],
      nacionalidad: map['nacionalidad'],
      fechaHora: DateTime.fromMillisecondsSinceEpoch(map['fecha_hora']),
      ubicacionGPS: map['ubicacion_gps'],
      descripcion: map['descripcion'] ?? '',
      fotoPath: map['foto_path'],
      audioPath: map['audio_path'],
    );
  }

  PersonModel copyWith({
    int? id,
    String? nombre,
    int? edadEstimada,
    String? nacionalidad,
    DateTime? fechaHora,
    String? ubicacionGPS,
    String? descripcion,
    String? fotoPath,
    String? audioPath,
  }) {
    return PersonModel(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      edadEstimada: edadEstimada ?? this.edadEstimada,
      nacionalidad: nacionalidad ?? this.nacionalidad,
      fechaHora: fechaHora ?? this.fechaHora,
      ubicacionGPS: ubicacionGPS ?? this.ubicacionGPS,
      descripcion: descripcion ?? this.descripcion,
      fotoPath: fotoPath ?? this.fotoPath,
      audioPath: audioPath ?? this.audioPath,
    );
  }
}
