class ReviewModel {
  final double rating;
  final String comment;
  final String reviewerName;

  ReviewModel({
    required this.rating,
    required this.comment,
    required this.reviewerName,
  });

  factory ReviewModel.fromJson(Map<String, dynamic> json) {
    return ReviewModel(
      rating: double.tryParse(json['rating']?.toString() ?? '') ?? 0,
      comment: json['comment']?.toString() ?? '',
      reviewerName: json['reviewerName']?.toString() ?? '',
    );
  }
}
