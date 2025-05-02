class SignetsApiResponse<T> {
  final T? data;
  final String? error;

  SignetsApiResponse({this.data, this.error});

  factory SignetsApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Object? json) fromJsonT,
  ) {
    final erreur = json['erreur'] as String?;
    final dataKeys = json.keys.where((k) => k != 'erreur').toList();

    Object? dataJson;

    if (dataKeys.length == 1) {
      // Case 1: Wrapped data (e.g., "liste": [...])
      dataJson = json[dataKeys.first];
    } else if (dataKeys.isNotEmpty) {
      // Case 2: Unwrapped data (e.g., student info directly in the root)
      final dataMap = Map<String, dynamic>.from(json)..remove('erreur');
      dataJson = dataMap;
    }

    return SignetsApiResponse(
      data: dataJson != null ? fromJsonT(dataJson) : null,
      error: erreur,
    );
  }

  Map<String, dynamic> toJson(Object Function(T value) toJsonT) => {
    'erreur': error,
    if (data != null) 'data': toJsonT(data!),
  };
}
