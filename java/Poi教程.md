# Poi教程
 
## 对象说明
### excel
* HSSFWorkbook － 提供读写Microsoft Excel XLS格式档案的功能。
* XSSFWorkbook － 提供读写Microsoft Excel OOXML XLSX格式档案的功能。


### word
* HWPFDocument － 提供读写Microsoft Word DOC97格式档案的功能。
* XWPFDocument － 提供读写Microsoft Word DOC2003格式档案的功能。

### 其他
* HSLF － 提供读写Microsoft PowerPoint格式档案的功能。
* HDGF － 提供读Microsoft Visio格式档案的功能。
* HPBF － 提供读Microsoft Publisher格式档案的功能。
* HSMF － 提供读Microsoft Outlook格式档案的功能。


## XSSFWorkbook
### 集合生成excel

* 调用范例
```
public class TestDataList {

    @ColumnDescription(columnName = "年龄")
    private String name;


    @ColumnDescription(columnName = "岁数")
    private  int age;
```

```
  public static void main(String[] args) throws IOException {


        List<TestDataList> lists = new ArrayList<>();
        TestDataList testDataList = new TestDataList();
        testDataList.setName("小明");
        testDataList.setAge(18);
        lists.add(testDataList);
        lists.add(testDataList);
        lists.add(testDataList);


        ExcelExporter excelExporter = new ExcelExporter();
        excelExporter.setStartCellIndex(1);
        excelExporter.addSheet(lists, TestDataList.class);
        excelExporter.addSheet(lists, TestDataList.class,"备份");
        excelExporter.addMergedRegion(0,0,0,10,"0","合并");
        byte[] bytes = excelExporter.list2Excel();
        FileUtils.writeByteArrayToFile(new File("C:\\Users\\xxx\\Desktop\\test.xlsx"), bytes);


    }
```

* ExcelExporter
```

import org.apache.poi.ss.util.CellRangeAddress;
import org.apache.poi.xssf.usermodel.XSSFCell;
import org.apache.poi.xssf.usermodel.XSSFRow;
import org.apache.poi.xssf.usermodel.XSSFSheet;
import org.apache.poi.xssf.usermodel.XSSFWorkbook;

import java.io.ByteArrayOutputStream;

import java.io.IOException;
import java.lang.reflect.Field;
import java.util.ArrayList;
import java.util.List;


public class ExcelExporter implements ObjectRelease {

    private int startRowIndex = 0;
    private int startCellIndex = 0;
    private String EMPTY_VALUE = "empty";
    private List<SheetDescription> list = new ArrayList<>();
    private int defaultSheetIndex = 0;
    private volatile byte[] exportData;

    @Override
    public void releaseResource() {
        list = null;
    }


    public void addSheet(List dataList, Class t) {
        String name = "" + defaultSheetIndex++;
        addSheet(dataList, t, name);
    }

    public void addSheet(List dataList, Class t, String sheetName) {
        SheetDescription sheetDescription = new SheetDescription();
        sheetDescription.setSheetName(sheetName);
        sheetDescription.setDataList(dataList);
        sheetDescription.settClass(t);
        sheetDescription.parseClass();

        list.add(sheetDescription);
    }

    public byte[] list2Excel() {
        if (exportData == null) {
            synchronized (this) {
                if (exportData == null) {
                    XSSFWorkbook xssfWorkbook = new XSSFWorkbook();
                    //create sheet
                    list.forEach(x -> {
                        XSSFSheet sheet = xssfWorkbook.createSheet(x.getSheetName());


                        //set the first title row
                        int rowIndex = startRowIndex;
                        List<String> columnNames = x.getColumnNames();
                        XSSFRow row = sheet.createRow(rowIndex);
                        int titleCellIndex = startCellIndex;
                        for (String s : columnNames) {
                            XSSFCell cell = row.createCell(titleCellIndex++);
                            cell.setCellValue(s);
                        }

                        //set follow row
                        List dataList = x.getDataList();
                        for (Object o : dataList) {
                            List<Object> list = object2ValueList(x, o);
                            XSSFRow row1 = sheet.createRow(++rowIndex);
                            int valueCellIndex = startCellIndex;
                            for (Object value : list) {
                                XSSFCell cell = row1.createCell(valueCellIndex++);
                                cell.setCellValue(value == null ? EMPTY_VALUE : value.toString());
                            }
                        }


                        //create merge
                        List<SheetDescription.MergeDescription> mergeDescriptions = x.getMergeDescriptions();
                        for (SheetDescription.MergeDescription mergeDescription : mergeDescriptions) {

                            //title
                            XSSFRow row2 = sheet.getRow(0);
                            XSSFCell cell1 = row2.getCell(mergeDescription.getStartCell());
                            if (cell1==null){
                                cell1= row2.createCell(mergeDescription.getStartCell());
                            }
                            cell1.setCellValue(mergeDescription.getMergeTitle());


                            //merge content
                            CellRangeAddress region = mergeDescription.createMerge();
                            sheet.addMergedRegion(region);
                            XSSFRow row1 = sheet.getRow(mergeDescription.getStartRow());
                            XSSFCell cell = row1.getCell(mergeDescription.getStartCell());
                            if (cell==null){
                                cell= row1.createCell(mergeDescription.getStartCell());
                            }
                            cell.setCellValue(mergeDescription.getMergeContent());
                        }


                    });


                    ByteArrayOutputStream byteArrayOutputStream = new ByteArrayOutputStream();
                    try {
                        xssfWorkbook.write(byteArrayOutputStream);
                        exportData = byteArrayOutputStream.toByteArray();
                    } catch (IOException e) {
                        throw new NullPointerException("write to byte array fail,cause " + e);
                    }
                }
            }
        }
        releaseResource();
        return exportData;
    }


    /**
     * 对象输出值列表
     *
     * @param o
     * @return
     */
    public List<Object> object2ValueList(SheetDescription sheetDescription, Object o) {
        List<Field> fieldList = sheetDescription.getFieldList();
        List<Object> list = new ArrayList<>();
        fieldList.forEach(x -> {
            try {
                Object value = x.get(o);
                list.add(value);
            } catch (IllegalAccessException e) {
                throw new RuntimeException("get value fail,cause " + e);
            }
        });
        return list;

    }

    /* ===============getter setter=============== */

    public int getStartRowIndex() {
        return startRowIndex;
    }

    public void setStartRowIndex(int startRowIndex) {
        this.startRowIndex = startRowIndex;
    }

    public int getStartCellIndex() {
        return startCellIndex;
    }

    public void setStartCellIndex(int startCellIndex) {
        this.startCellIndex = startCellIndex;
    }

    public String getEMPTY_VALUE() {
        return EMPTY_VALUE;
    }

    public void setEMPTY_VALUE(String EMPTY_VALUE) {
        this.EMPTY_VALUE = EMPTY_VALUE;
    }

    /**
     * 添加合并的单元格
     * @param startRow 起使行
     * @param endRow 结束行
     * @param startCell 起使列
     * @param endCell 结束列
     * @param sheetName sheet名
     * @param mergeContent 合并填充内容
     * @param mergeTitle 列标题
     */
    public void addMergedRegion(int startRow, int endRow, int startCell, int endCell, String sheetName, String mergeContent, String mergeTitle) {

        for (SheetDescription sheetDescription : list) {
            if (sheetName.equals(sheetDescription.getSheetName())) {
                List<SheetDescription.MergeDescription> mergeDescriptions = sheetDescription.getMergeDescriptions();
                mergeDescriptions.add(new SheetDescription.MergeDescription(startRow, endRow, startCell, endCell, mergeContent,mergeTitle));
                return;
            }
        }
        throw new RuntimeException("can not found the sheet");
    }
}

```

* SheetDescription
```

import org.apache.poi.ss.util.CellRangeAddress;

import java.lang.reflect.Field;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;
import java.util.stream.Stream;

public class SheetDescription implements ObjectRelease {
    private String sheetName;

    private Class tClass;

    private List dataList;

    private List<String> columnNames;

    private List<Field> fieldList;

    private List<MergeDescription> mergeDescriptions=new ArrayList<>();

    private static final Map<Class, InnerReflectCache> map = new ConcurrentHashMap<>();

    @Override
    public void releaseResource() {
        tClass = null;
        dataList = null;
        fieldList = null;
        mergeDescriptions=null;
    }


    /**
     * need cache
     */
    public void parseClass() {
        InnerReflectCache innerReflectCache = map.get(tClass);
        if (innerReflectCache == null) {
            synchronized (SheetDescription.class){
                if (innerReflectCache == null) {
                    innerReflectCache = new InnerReflectCache();
                    Field[] declaredFields = tClass.getDeclaredFields();
                    List<String> nList = new ArrayList<>();
                    List<Field> fList = new ArrayList<>();


                    Stream.of(declaredFields).forEach(x -> {
                        x.setAccessible(true);
                        fList.add(x);
                        ColumnDescription annotation = x.getAnnotation(ColumnDescription.class);
                        if (annotation == null) {
                            nList.add(x.getName());
                        } else {
                            String name = annotation.columnName();
                            nList.add(name);
                        }

                    });
                    innerReflectCache.setColumnNames(nList);
                    innerReflectCache.settClass(tClass);
                    innerReflectCache.setFieldList(fList);
                    map.put(tClass, innerReflectCache);
                }
            }
        }
        columnNames = innerReflectCache.getColumnNames();
        fieldList = innerReflectCache.getFieldList();

    }

    public List<Field> getFieldList() {
        return fieldList;
    }

    public List<String> getColumnNames() {
        return columnNames;
    }

    public void setColumnNames(List<String> columnNames) {
        this.columnNames = columnNames;
    }

    public String getSheetName() {
        return sheetName;
    }

    public void setSheetName(String sheetName) {
        this.sheetName = sheetName;
    }

    public Class gettClass() {
        return tClass;
    }

    public void settClass(Class tClass) {
        this.tClass = tClass;
    }

    public List getDataList() {
        return dataList;
    }

    public void setDataList(List dataList) {
        this.dataList = dataList;
    }


    public List<MergeDescription> getMergeDescriptions() {
        return mergeDescriptions;
    }

    public void setMergeDescriptions(List<MergeDescription> mergeDescriptions) {
        this.mergeDescriptions = mergeDescriptions;
    }

    public  static class MergeDescription {


        private int startRow;

        private int endRow;

        private int startCell;

        private int endCell;

        private String mergeTitle;

        private String mergeContent;


        public  MergeDescription(int startRow, int endRow, int startCell, int endCell, String mergeContent,String mergeTitle) {
            this.startRow = startRow;
            this.endRow = endRow;
            this.startCell = startCell;
            this.endCell = endCell;
            this.mergeContent = mergeContent;
            this.mergeTitle = mergeTitle;
        }

        public CellRangeAddress createMerge() {
            CellRangeAddress cellRangeAddress = new CellRangeAddress(startRow,endRow,startCell,endCell);
            return cellRangeAddress;
        }

        public String getMergeTitle() {
            return mergeTitle;
        }

        public void setMergeTitle(String mergeTitle) {
            this.mergeTitle = mergeTitle;
        }

        public int getStartRow() {
            return startRow;
        }

        public void setStartRow(int startRow) {
            this.startRow = startRow;
        }

        public int getEndRow() {
            return endRow;
        }

        public void setEndRow(int endRow) {
            this.endRow = endRow;
        }

        public int getStartCell() {
            return startCell;
        }

        public void setStartCell(int startCell) {
            this.startCell = startCell;
        }

        public int getEndCell() {
            return endCell;
        }

        public void setEndCell(int endCell) {
            this.endCell = endCell;
        }

        public String getMergeContent() {
            return mergeContent;
        }

        public void setMergeContent(String mergeContent) {
            this.mergeContent = mergeContent;
        }


    }


    public class InnerReflectCache {
        private Class tClass;

        private List<String> columnNames;

        private List<Field> fieldList;

        public Class gettClass() {
            return tClass;
        }

        public void settClass(Class tClass) {
            this.tClass = tClass;
        }

        public List<String> getColumnNames() {
            return columnNames;
        }

        public void setColumnNames(List<String> columnNames) {
            this.columnNames = columnNames;
        }

        public List<Field> getFieldList() {
            return fieldList;
        }

        public void setFieldList(List<Field> fieldList) {
            this.fieldList = fieldList;
        }
    }
}

```

*  ObjectRelease
```
public interface ObjectRelease {

    public void releaseResource();
}
```


*  ColumnDescription
```
import java.lang.annotation.*;

@Documented
@Retention(RetentionPolicy.RUNTIME)
@Target({ElementType.FIELD})
public @interface ColumnDescription {

    String columnName() default "";
}
```


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




