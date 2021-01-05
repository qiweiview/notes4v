# Poi教程
 
## 对象说明
* HSSFWorkbook － 提供读写Microsoft Excel XLS格式档案的功能。
* XSSFWorkbook － 提供读写Microsoft Excel OOXML XLSX格式档案的功能。

-----------

* HWPFDocument － 提供读写Microsoft Word DOC97格式档案的功能。
* XWPFDocument － 提供读写Microsoft Word DOC2003格式档案的功能。

-----------
* HSLF － 提供读写Microsoft PowerPoint格式档案的功能。
* HDGF － 提供读Microsoft Visio格式档案的功能。
* HPBF － 提供读Microsoft Publisher格式档案的功能。
* HSMF － 提供读Microsoft Outlook格式档案的功能。

## XWPFDocument 
```
// 段落
List<XWPFParagraph> paragraphs = doc.getParagraphs();
// 表格
List<XWPFTable> tables = doc.getTables();
// 图片
List<XWPFPictureData> allPictures = doc.getAllPictures();
// 页眉
List<XWPFHeader> headerList = doc.getHeaderList();
// 页脚
List<XWPFFooter> footerList = doc.getFooterList();
```




