# 解压
ls *.tar.gz | xargs -n1 tar xzvf
# 安装库
cd MarkupSafe-0.23
python setup.py install
cd ../
cd Jinja2-2.10.3
python setup.py install
cd ../
cd PyYAML-5.1
python setup.py install
cd ../
cd meld3-1.0.1
python setup.py install
cd ../
cd supervisor-3.3.1
python setup.py install
