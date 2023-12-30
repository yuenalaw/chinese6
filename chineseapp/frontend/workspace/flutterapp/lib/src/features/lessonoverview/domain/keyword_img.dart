class KeywordImg {
  final String img;
  final String keyword;

  KeywordImg({required this.img, required this.keyword});

  factory KeywordImg.fromJson(Map<String, dynamic> json) {
    return KeywordImg(
      img: json['img'],
      keyword: json['keyword'],
    );
  }
}