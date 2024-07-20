# Elkeid - Bytedance Cloud Workload Protection Platform



<font color=FF0000  size=42> 化繁为简  为爱发电</font>


## 启动
```shell
docker-compose up -d
```


**Elkeid** 是一款可以满足 **主机，容器与容器集群，Serverless** 等多种工作负载安全需求的开源解决方案，源于字节跳动内部最佳实践。



查看详细介绍，请移步至 https://github.com/bytedance/Elkeid



### 能力介绍

1. 主机防护
2. 容器防护（无需部署到容器中）
3. 服务探针 RASP



## Elkeid Architecture

<img src="server/docs/server_new.png"/>

##  Elkeid Host Ability
* **[Elkeid Agent](agent/README-zh_CN.md)** 用户态 Agent，负责管理各个端上能力组件并与 **Elkeid Agent Center** 通信
* **[Elkeid Driver](driver/README-zh_CN.md)** 负责 Linux Kernel 层采集数据，兼容容器，并能够检测常见 Rootkit
* **[Elkeid RASP](rasp)** 支持 CPython、Golang、JVM、NodeJS、PHP 的运行时数据采集探针，支持动态注入到运行时
* **Elkeid Agent Plugin List**
  * [Driver Plugin](plugins/driver): 负责与 **Elkeid Driver** 通信，处理其传递的数据等
  * [Collector Plugin](plugins/collector): 负责端上的资产/关键信息采集工作，如用户，定时任务，包信息等
  * [Journal Watcher](plugins/journal_watcher): 负责监测systemd日志的插件，目前支持ssh相关日志采集与上报
  * [Scanner Plugin](plugins/scanner): 负责在端上进行静态检测恶意文件的插件，支持 Yara
  * [RASP Plugin](rasp/plugin): 分析系统进程运行时，上报运行时信息，处理下发的 Attach 指令，收集各个探针上报的数据
  * [Baseline Plugin](plugins/baseline): 负责在端上进行基线风险识别的插件
* [**Elkeid 数据说明**](server/docs/ElkeidData.xlsx)
* [**Elkeid 数据接入**](elkeidup/raw_data_usage_tutorial/raw_data_usage_tutorial-zh_CN.md)


## Elkeid Backend Ability
* **[Elkeid AgentCenter](server/agent_center)** 负责与 Agent 进行通信并管理 Agent 如升级，配置修改，任务下发等
* **[Elkeid ServiceDiscovery](server/service_discovery)** 后台中的各组件都会向该组件定时注册、同步服务信息，从而保证各组件相互可见，便于直接通信
* **[Elkeid Manager](server/manager)** 负责对整个后台进行管理，并提供相关的查询、管理接口
* **[Elkeid Console](server/web_console)** Elkeid 前端部分
* **[Elkeid HUB](https://github.com/bytedance/Elkeid-HUB)**  策略引擎



## Elkeid Function List

| 功能                 | Elkeid Community Edition | Elkeid Enterprise Edition |
|--------------------|--------------------------|---------------------------|
| Linux 数据采集能力       | :white_check_mark:       | :white_check_mark:        |
| RASP 探针能力          | :white_check_mark:       | :white_check_mark:        |
| K8s Audit Log 采集能力 | :white_check_mark:       | :white_check_mark:        |
| Agent 控制面          | :white_check_mark:       | :white_check_mark:        |
| 主机状态与详情            | :white_check_mark:       | :white_check_mark:        |
| 勒索诱饵               | :ng_man:                 | :white_check_mark:        |
| 资产采集               | :white_check_mark:       | :white_check_mark:        |
| 高级资产采集             | :ng_man:                 | :white_check_mark:        |
| 容器集群资产采集           | :white_check_mark:       | :white_check_mark:        |
| 暴露面与脆弱性分析          | :ng_man:                 | :white_check_mark:        |
| 主机/容器 基础入侵检测       | `少量样例`                   | :white_check_mark:        |
| 主机/容器 行为序列入侵检测     | :ng_man:                 | :white_check_mark:        |
| RASP 基础入侵检测        | `少量样例`                   | :white_check_mark:        |
| RASP 行为序列入侵检测      | :ng_man:                 | :white_check_mark:        |
| K8S 基础入侵检测         | `少量样例`                   | :white_check_mark:        |
| K8S 行为序列入侵检测       | :ng_man:                 | :white_check_mark:        |
| K8S 威胁分析           | :ng_man:                 | :white_check_mark:        |
| 告警溯源(行为溯源)         | :ng_man:                 | :white_check_mark:        |
| 告警溯源(驻留溯源)         | :ng_man:                 | :white_check_mark:        |
| 告警白名单              | :white_check_mark:       | :white_check_mark:        |
| 多告警聚合能力            | :ng_man:                 | :white_check_mark:        |
| 威胁处置(进程)           | :ng_man:                 | :white_check_mark:        |
| 威胁处置(网络)           | :ng_man:                 | :white_check_mark:        |
| 威胁处置(文件)           | :ng_man:                 | :white_check_mark:        |
| 文件隔离箱              | :ng_man:                 | :white_check_mark:        |
| 漏洞检测               | `少量情报`                   | :white_check_mark:        |
| 漏洞情报热更新            | :ng_man:                 | :white_check_mark:        |
| 基线检查               | `少量基线`                   | :white_check_mark:        |
| RASP 热补丁           | :ng_man:                 | :white_check_mark:        |
| 病毒扫描               | :white_check_mark:       | :white_check_mark:        |
| 用户行为日志分析           | :ng_man:                 | :white_check_mark:        |
| 插件管理               | :white_check_mark:       | :white_check_mark:        |
| 系统监控               | :white_check_mark:       | :white_check_mark:        |
| 系统管理               | :white_check_mark:       | :white_check_mark:        |
| Windows 支持         | :ng_man:                 | :white_check_mark:        |
| 蜜罐                 | :ng_man:                 | :oncoming_automobile:     |
| 主动防御               | :ng_man:                 | :oncoming_automobile:     |
| 云查杀                | :ng_man:                 | :oncoming_automobile:     |
| 防篡改                | :ng_man:                 | :oncoming_automobile:     |

