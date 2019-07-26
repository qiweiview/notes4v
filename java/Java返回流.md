```
@RequestMapping(value = "/file/{msg}")
    public ResponseEntity<byte[]> downloadFile(@PathVariable String msg) throws IOException {
        byte[] bytes = msg.getBytes();
        HttpHeaders headers = new HttpHeaders();
        headers.setContentType(MediaType.APPLICATION_OCTET_STREAM);
        headers.setContentDisposition(ContentDisposition.parse("attachment;filename=1.txt"));
        return new ResponseEntity<>(bytes, headers, HttpStatus.CREATED);
    }
```
