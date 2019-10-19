import 'package:xml/xml.dart' as xml;

class FileInfo {
  String path;
  String size;
  String modificationTime;
  DateTime creationTime;
  String contentType;

  FileInfo(this.path, this.size, this.modificationTime, this.creationTime,
      this.contentType);

  // Returns the decoded name of the file / folder without the whole path
  String get name {
    if (this.isDirectory) {
      return Uri.decodeFull(
          this.path.substring(0, this.path.lastIndexOf("/")).split("/").last);
    }

    return Uri.decodeFull(this.path.split("/").last);
  }

  bool get isDirectory => this.path.endsWith("/");

  @override
  String toString() {
    return 'FileInfo{name: $name, isDirectory: $isDirectory, path: $path, size: $size, modificationTime: $modificationTime, creationTime: $creationTime, contentType: $contentType}';
  }
}

/// get field [name] from the property node
String prop(dynamic prop, String name, [String defaultVal]) {
  if (prop is Map) {
    final val = prop['D:' + name];
    if (val == null) {
      return defaultVal;
    }
    return val;
  }
  return defaultVal;
}

List<FileInfo> treeFromWevDavXml(String xmlStr) {
  // Initialize a list to store the FileInfo Objects
  final tree = List<FileInfo>();

  // parse the xml using the xml.parse method
  final xmlDocument = xml.parse(xmlStr);

  String _getElementWithDefault(
      xml.XmlElement element, String name, String defaultVal) {
    final iterable = element.findAllElements(name);
    return iterable.isEmpty ? defaultVal : iterable.single.text;
  }

  // Iterate over the response to find all folders / files and parse the information
  xmlDocument.findAllElements("d:response").forEach((response) {
    final davItemName = response.findElements("d:href").single.text;
    response
        .findElements("d:propstat")
        .single
        .findElements("d:prop")
        .forEach((element) {
      final contentLength =
          _getElementWithDefault(element, 'd:getcontentlength', '???');

      final lastModified =
          _getElementWithDefault(element, 'd:getlastmodified', '???');

      final creationTime = DateTime.parse(
          _getElementWithDefault(element, 'd:creationdate', '1970-01-01'));

      // Add the just found file to the tree
      tree.add(
          FileInfo(davItemName, contentLength, lastModified, creationTime, ""));
    });
  });

  // Return the tree
  return tree;
}
