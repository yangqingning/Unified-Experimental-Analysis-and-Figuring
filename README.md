本工具箱立志收集管吉松实验室所有数据分析作图代码，并使用统一的UniExp格式。

依赖[埃博拉酱的全局优化工具箱](https://ww2.mathworks.cn/matlabcentral/fileexchange/101368-plot-color-allocate-optimization)、[埃博拉酱的并行计算工具箱](https://ww2.mathworks.cn/matlabcentral/fileexchange/99194-parallel-computing)、[埃博拉酱的图像处理工具箱](https://ww2.mathworks.cn/matlabcentral/fileexchange/117015-image-processing-toolbox)、[Image5D](https://ww2.mathworks.cn/matlabcentral/fileexchange/114435-image5d-oir-tiff)

# UniExp数据集格式 
UniExp是一种模仿SQL数据库架构的MATLAB表格组，由6张符合BC范式的数据表组成，每张表包含主键和必选列，可以额外添加可选列：
- Mice，主键Mouse，鼠名。本表其它列可选，但应当是与该鼠特定的信息，如实验范式等。
- DateTimes，主键DateTime，实验进行的时间日期，本表其它列可选，但应当是与该次实验特定的信息，例如鼠、拍摄采样率、元数据等
- Blocks，主键BlockUID，模块的唯一标识符；码(DateTime,BlockIndex)，因为“一次特定实验的第N个模块”应当可以唯一确定一个模块。主键和码应当一一对应且不能重复。其它可选列应当是特定于该模块的信息，如模块设计名称、标通道值、事件日志等
- Trials，主键TrialUID，回合的唯一标识符；码(BlockUID,TrialIndex)，因为“一个特定模块的第N回合”应当可以唯一确定一个回合。其它可选列应当是特定于该回合的信息，如刺激类型、标通道值、采样时点、动物行为等。
- Cells，主键CellUID，细胞的唯一标识符；码(Mouse,ZLayer,CellType,CellIndex)，因为“一只鼠某层某种类型的第N个细胞”应当可以唯一确定一个细胞。其它可选列应当是特定于该细胞的信息，如像素位置等。
- BlockSignals，主键(CellUID,BlockUID)，用模块和细胞的组合唯一标识该细胞在该模块的活动，可选列如BlockSignal等
- TrialSignals，主键(CellUID,TrialUID)，用回合和细胞的组合唯一标识该细胞在该回合的活动，可选列如TrialSignal等

上述数据表合并为UniExp.DataSet对象。每个表均为可选留空。

这些表格可以使用【埃博拉酱的MATLAB扩展】中的MATLAB.DataTypes.Select方法进行基本的连接查询。有些 UniExp API 会要求以查询结果作为输入。
# UniExp数据文件名
为了支持从数据文件中直接提取基本元数据的功能，请以UniExp标准格式命名数据文件：
`<鼠名>.<日期时间>.<会话设计名>[.<其它可选字段>].UniExp.mat`
例如
`0040.202207151026.BlueAudioWater.UniExp.mat`
`0040.202207151026.BlueAudioWater.行为.UniExp.mat`
许多API都能自动检测标准文件名，自动生成元数据。如果文件名不合标准，将发出警告，但程序仍可运行，只是会缺少部分元数据。
# UniExp API
为了获取、处理和使用UniExp格式文件，本工具箱包含一系列数据处理函数，都在UniExp包内，使用前需导入：
```MATLAB
import UniExp.*
```
每个函数代码文件内都有详尽文档，可用`doc UniExp.函数名`查询。函数的使用示例可在快速入门文档GettingStarted.mlx中查看。下方仅列出这些函数的简介。
## UniExp.DataSet类
用于管理数据集的核心实用类：
```MATLAB
classdef DataSet
	%UniExp数据集大类，包含多种处理、分析方法，是实现统一实验分析作图的通用数据集类型。
end
```
## 原始数据预处理
```MATLAB
%从一群ImageJ ROI中减去另一群ImageJ ROI，即作差集。仅比较每个ROI的文件名，文件名相同即认为ROI相同。
function RoiCPath=ImageJRoiDiff(options)
%对OIR文件进行等时距采样然后输出平均TIFF
function OirSampleMean(OirPath,options)
%根据 ImageJ RoiSet 配准图像
function TransMatrix = RoiRegister(PathArray,varargin)
%批量配准 Olympus OIR 文件并转码为OME-TIFF格式，自动排除电流检测（Current Detector, CD）通道
function BatchOirRegisterTiff(OirPaths,FixedPath,OutputDirectory,TransMatrix,options)
对Tiff图像批量应用变换矩阵
function BatchTiffTransform(TiffTransTable,OutputDirectory)
```
## 从其它数据文件格式取得UniExp
```MATLAB
%批量测量OME-TIFF，以UniExp格式存储测量结果
function BatchTiffMeasure(TiffPaths,ImageJRoiPaths,ScatterRadius,MeanTiff,options)
%为多个视频批量输出平均图
function BatchVideoMean(VideoPaths,Output)
%将多个视频文件按照 ImageJ ROI 测量后输出到UniExp数据库
function BatchVideoMeasure(VideoPaths,ImageJRoiPaths,RoiName,Algorithm,options)
%从Rdc2格式转换为UniExp规范DataSet格式
function DataSet = Rdc2DataSet(Rdc2DataPaths)
从表格文件读入查询表
function QueryTable = ReadQueryTable(TablePath)
```
## UniExp内部处理
```MATLAB
%用误差条形图和散点对两组采样数据进行比较，并显示 t test p 值
function BarScatterCompare(DataA,DataB,varargin)
%作异形彩色标记线条图
function Scatters = ColorfulMarkerPlot(Points,LineColors,MarkerIndex,MarkerShape,MarkerColors,options)
%从事件记录取得表现分数
function Performance = EventLog2Performance(EventLogs,Events)
%绘制分泳道的热图
function [Layout,Axes]=LanearHeatmap(NTATS,Flags,options)
%生成带有平均值和标准误的学习曲线数据（不作图）和学会天数的总结表
function Summary=LearningSummarize(SessionTable,LearnedP)
%对NTATS数据，将所有参与细胞的信号主成分分析，生成主成分空间中的典型时间曲线图。主成分是细胞的加权和。
function [PcaLines,Explained,Coeff] = LinearPca(NTATS,NumComponents)
%设置或取得Rdc2全局忽略关键词
function IgnoreKeywords = Rdc2IgnoreKeywords(IgnoreKeywords)
%绘制带有关键时点标识的渐淡线图
function [Lines,Scatters]=SegmentFadePlot(Points,LineColors,KeyIndex,KeyMarkers,options)
%根据信号拆分回合
function [Trials,TrialSignals] = SignalSplitTrial(Query,TimeRange,SplitType,StdCutoff)
%根据回合信号判断行为
function Behavior = TrialSignal2Behavior(TrialSignal,SampleRate,CStartTime,CEndTime,UStartTime,SignalType,ReferenceType,options)
```