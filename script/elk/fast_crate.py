# -*- coding: UTF-8 -*-

#
# 脚本依赖yaml和jinja2库
#
import os
import yaml
from jinja2 import Environment, FileSystemLoader




# 解析配置文件
def parseConfig( fileName ):
		f = open(fileName,'r')
		json = yaml.load(f,Loader=yaml.FullLoader)
		for po in json['projects']:
			if(not os.path.exists(po['path'])):
				raise IOError('脚本中断,项目路径'+po['path']+'不存在,无法生成对应配置文件')
  		return json

# 创建日志输出目录
def createLogDirect( log_path ):
		if(not os.path.exists(log_path)):
			os.makedirs(log_path)
			print '\n创建日志输出目录'+log_path
		else:
			print '\n日志出书目录'+log_path+'已存在,不另行创建'   

# 替换项目中的日志配置文件
def createLogConfig( host,appName,log_output,config_output ):
	env = Environment(loader = FileSystemLoader("./template/"))
	template = env.get_template("log4j.properties")
	content = template.render(logDir=log_output, host=host, appName=appName)
	with open(config_output,'w') as fp:
		fp.write(content)
	print '创建替换配置文件:'+config_output

# 替换filebeat配置文件
def createFilebeatConfig( logstash_host,config_output,project_list ):
	project_yml_list=''
        obj_list=[]
	
	for pj in project_list:
		obj_list.append({'type':'log','enable':True,'paths':[ pj['log_path']+'/*.log' ]})
	
	project_yml_list= yaml.dump(obj_list)
        env = Environment(loader = FileSystemLoader("./template/"))
        template = env.get_template("filebeat.yml")
        content = template.render(logstash_host=logstash_host,project_list=project_yml_list)
	with open(config_output,'w') as fp:
                fp.write(content)
       
	print '创建filebeat配置文件:'+config_output
