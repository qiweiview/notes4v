# -*- coding: UTF-8 -*-
import fast_crate

def main():
	print '===脚本开始运行==='
	
	#json=fast_crate.parseConfig('project_info_demo.yml')
        json=fast_crate.parseConfig('demo.yml')
	for project in json['projects']:
		pass

		# 创建日志输出文件夹
		fast_crate.createLogDirect(project['log_path'])
		
		# 创建日志配置文件
		fast_crate.createLogConfig(json['host'],project['name'],project['log_path']+'/log.log',project['path']+'/log4j.properties')

	# 替换filebaeat配置文件
	fast_crate.createFilebeatConfig(json['logstash_host'],json['filebeat_path']+'/filebeat.yml',json['projects'])

	print '===脚本运行完成==='

main()
