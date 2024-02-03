import 'dart:convert';

class Results {
  String? kind;
  Url? url;
  Queries? queries;
  Context? context;
  SearchInformation? searchInformation;
  List<Item>? items;

  Results({
    required this.kind,
    required this.url,
    required this.queries,
    required this.context,
    required this.searchInformation,
    required this.items,
  });

  factory Results.fromRawJson(String str) => Results.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory Results.fromJson(Map<String, dynamic> json) => Results(
        kind: json["kind"],
        url: json["url"] == null ? null : Url.fromJson(json["url"]),
        queries: json["queries"] == null ? null : Queries.fromJson(json["queries"]),
        context: json["context"] == null ? null : Context.fromJson(json["context"]),
        searchInformation: json["searchInformation"] == null
            ? null
            : SearchInformation.fromJson(json["searchInformation"]),
        items: json["items"] == null
            ? null
            : List<Item>.from(json["items"].map((x) => Item.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "kind": kind,
        "url": url == null ? null : url?.toJson(),
        "queries": queries == null ? null : queries?.toJson(),
        "context": context == null ? null : context?.toJson(),
        "searchInformation": searchInformation == null ? null : searchInformation?.toJson(),
        "items": items == null ? null : List<dynamic>.from(items!.map((x) => x.toJson())),
      };
}

class Context {
  String? title;

  Context({
    required this.title,
  });

  factory Context.fromRawJson(String str) => Context.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory Context.fromJson(Map<String, dynamic> json) => Context(
        title: json["title"],
      );

  Map<String, dynamic> toJson() => {
        "title": title,
      };
}

class Item {
  Kind? kind;
  String? title;
  String? htmlTitle;
  String? link;
  String? displayLink;
  String? snippet;
  String? htmlSnippet;
  Mime? mime;
  Image? image;

  Item({
    this.kind,
    this.title,
    this.htmlTitle,
    this.link,
    this.displayLink,
    this.snippet,
    this.htmlSnippet,
    this.mime,
    this.image,
  });

  factory Item.fromRawJson(String str) => Item.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory Item.fromJson(Map<String, dynamic> json) => Item(
        kind: json["kind"] == null ? null : kindValues.map[json["kind"]],
        title: json["title"],
        htmlTitle: json["htmlTitle"],
        link: json["link"],
        displayLink: json["displayLink"],
        snippet: json["snippet"],
        htmlSnippet: json["htmlSnippet"],
        mime: json["mime"] == null ? null : mimeValues.map[json["mime"]],
        image: json["image"] == null ? null : Image.fromJson(json["image"]),
      );

  Map<String, dynamic> toJson() => {
        "kind": kind == null ? null : kindValues.reverse[kind],
        "title": title,
        "htmlTitle": htmlTitle,
        "link": link,
        "displayLink": displayLink,
        "snippet": snippet,
        "htmlSnippet": htmlSnippet,
        "mime": mime == null ? null : mimeValues.reverse[mime],
        "image": image == null ? null : image!.toJson(),
      };
}

class Image {
  String? contextLink;
  int? height;
  int? width;
  int? byteSize;
  String? thumbnailLink;
  int? thumbnailHeight;
  int? thumbnailWidth;

  Image({
    this.contextLink,
    this.height,
    this.width,
    this.byteSize,
    this.thumbnailLink,
    this.thumbnailHeight,
    this.thumbnailWidth,
  });

  factory Image.fromRawJson(String str) => Image.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory Image.fromJson(Map<String, dynamic> json) => Image(
        contextLink: json["contextLink"],
        height: json["height"],
        width: json["width"],
        byteSize: json["byteSize"],
        thumbnailLink: json["thumbnailLink"],
        thumbnailHeight: json["thumbnailHeight"],
        thumbnailWidth: json["thumbnailWidth"],
      );

  Map<String, dynamic> toJson() => {
        "contextLink": contextLink,
        "height": height,
        "width": width,
        "byteSize": byteSize,
        "thumbnailLink": thumbnailLink,
        "thumbnailHeight": thumbnailHeight,
        "thumbnailWidth": thumbnailWidth,
      };
}

enum Kind { CUSTOMSEARCH_RESULT }

final kindValues = EnumValues({"customsearch#result": Kind.CUSTOMSEARCH_RESULT});

enum Mime { IMAGE_JPEG, IMAGE, IMAGE_PNG }

final mimeValues = EnumValues(
    {"image/": Mime.IMAGE, "image/jpeg": Mime.IMAGE_JPEG, "image/png": Mime.IMAGE_PNG});

class Queries {
  List<NextPage>? request;
  List<NextPage>? nextPage;

  Queries({
    this.request,
    this.nextPage,
  });

  factory Queries.fromRawJson(String str) => Queries.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory Queries.fromJson(Map<String, dynamic> json) => Queries(
        request: json["request"] == null
            ? null
            : List<NextPage>.from(json["request"].map((x) => NextPage.fromJson(x))),
        nextPage: json["nextPage"] == null
            ? null
            : List<NextPage>.from(json["nextPage"].map((x) => NextPage.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "request": request == null ? null : List<dynamic>.from(request!.map((x) => x.toJson())),
        "nextPage":
            nextPage == null ? null : List<dynamic>.from(nextPage!.map((x) => x.toJson())),
      };
}

class NextPage {
  String? title;
  String? totalResults;
  String? searchTerms;
  int? count;
  int? startIndex;
  String? inputEncoding;
  String? outputEncoding;
  String? safe;
  String? cx;
  String? searchType;

  NextPage({
    this.title,
    this.totalResults,
    this.searchTerms,
    this.count,
    this.startIndex,
    this.inputEncoding,
    this.outputEncoding,
    this.safe,
    this.cx,
    this.searchType,
  });

  factory NextPage.fromRawJson(String str) => NextPage.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory NextPage.fromJson(Map<String, dynamic> json) => NextPage(
        title: json["title"],
        totalResults: json["totalResults"],
        searchTerms: json["searchTerms"],
        count: json["count"],
        startIndex: json["startIndex"],
        inputEncoding: json["inputEncoding"],
        outputEncoding: json["outputEncoding"],
        safe: json["safe"],
        cx: json["cx"],
        searchType: json["searchType"],
      );

  Map<String, dynamic> toJson() => {
        "title": title,
        "totalResults": totalResults,
        "searchTerms": searchTerms,
        "count": count,
        "startIndex": startIndex,
        "inputEncoding": inputEncoding,
        "outputEncoding": outputEncoding,
        "safe": safe,
        "cx": cx,
        "searchType": searchType,
      };
}

class SearchInformation {
  double? searchTime;
  String? formattedSearchTime;
  String? totalResults;
  String? formattedTotalResults;

  SearchInformation({
    this.searchTime,
    this.formattedSearchTime,
    this.totalResults,
    this.formattedTotalResults,
  });

  factory SearchInformation.fromRawJson(String str) => SearchInformation.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory SearchInformation.fromJson(Map<String, dynamic> json) => SearchInformation(
        searchTime: json["searchTime"] == null ? null : json["searchTime"].toDouble(),
        formattedSearchTime:
            json["formattedSearchTime"],
        totalResults: json["totalResults"],
        formattedTotalResults:
            json["formattedTotalResults"],
      );

  Map<String, dynamic> toJson() => {
        "searchTime": searchTime,
        "formattedSearchTime": formattedSearchTime,
        "totalResults": totalResults,
        "formattedTotalResults": formattedTotalResults,
      };
}

class Url {
  String? type;
  String? template;

  Url({
    required this.type,
    required this.template,
  });

  factory Url.fromRawJson(String str) => Url.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory Url.fromJson(Map<String, dynamic> json) => Url(
        type: json["type"],
        template: json["template"],
      );

  Map<String, dynamic> toJson() => {
        "type": type,
        "template": template,
      };
}

class EnumValues<T> {
  Map<String, T> map;
  Map<T, String>? reverseMap;

  EnumValues(this.map);

  Map<T, String> get reverse {
    if (reverseMap == null) {
      reverseMap = map.map((k, v) => new MapEntry(v, k));
    }
    return reverseMap!;
  }
}