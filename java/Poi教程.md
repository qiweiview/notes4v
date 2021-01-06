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
### Word转Html Demo
* 未完善
```
public static void word2html(String wordPath) throws IOException {


        List<InnerElement> list=new ArrayList<>();
        Map<String,InnerElement> map=new HashMap<>();

        byte[] bytes = FileUtils.readFileToByteArray(new File(wordPath));

        XWPFDocument xssfWorkbook = new XWPFDocument(new ByteArrayInputStream(bytes));
        final AtomicInteger curP = new AtomicInteger();
        List<IBodyElement> bodyElements = xssfWorkbook.getBodyElements();
        bodyElements.forEach(x -> {

            if (x.getElementType().equals(BodyElementType.PARAGRAPH)) {
                IBody body = x.getBody();
                XWPFParagraph p = body.getParagraphArray(curP.get());
                String s = p.getCTP().xmlText();
                if (s.indexOf("<w:drawing>") != -1) {
                    int rIdIndex = s.indexOf("r:embed=");
                    int ridEndIndex = s.indexOf("/>", rIdIndex);
                    String rIdText = s.substring(rIdIndex + "r:embed=".length() + 1, ridEndIndex - 1);

                    InnerElement innerElement = new InnerElement(rIdText,1);
                    map.put(rIdText,innerElement);
                    list.add(innerElement);
                }
                if (s.indexOf("<w:t>") != -1) {
                    if (p.getParagraphText().length()>0){
                        InnerElement innerElement = new InnerElement(p.getParagraphText(), 0);
                        map.put(p.getParagraphText(),innerElement);
                        list.add(innerElement);
                    }

                }
                curP.incrementAndGet();
            }


        });



        List<XWPFPictureData> allPictures = xssfWorkbook.getAllPictures();
        allPictures.forEach(x -> {
            String id = x.getPackageRelationship().getId();
            InnerElement innerElement = map.get(id);
            if (innerElement!=null){
                byte[] data = x.getData();
                innerElement.setPicData(data);
            }
        });

        list.forEach(x->{
            System.out.println(x.toHtml());
        });

    }
    
    public static class InnerElement{
        private String data;
        private int type;
        private byte[] picData;

        public boolean isPic(){
            return type==1;
        }

        public InnerElement(String data, int type) {
            this.data = data;
            this.type = type;
        }

        public void setPicData(byte[] picData) {
            this.picData = picData;
        }

        public String toHtml() {
            if (isPic()){
                String s = Base64Utils.encodeToString(picData);
                return "<img class=\"block_display\" src=\"data:image/png;base64,"+s+"\"  />";
            }else {
                return "<span  class=\"block_display\" >"+data+"</span>";
            }
        }
    }
```




