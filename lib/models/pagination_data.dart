class PaginationData {
  final int currentPage;
  final int lastPage;
  final int perPage;
  final int total;

  PaginationData({
    required this.currentPage,
    required this.lastPage,
    required this.perPage,
    required this.total
  });

  factory PaginationData.fromJson(Map<String, dynamic> json) {
    return PaginationData(
      currentPage: json['current_page'],
      lastPage: json['last_page'],
      perPage: json['per_page'],
      total: json['total']
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'current_page': currentPage,
      'last_page': lastPage,
      'per_page': perPage,
      'total': total
    };
  }
}