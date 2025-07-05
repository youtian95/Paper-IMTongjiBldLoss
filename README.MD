# 基于地震动强度随机场的地震损失评估方法应用：以同济校园为例

## 论文信息
**游田**, 周绪红, 刘怡岑, 如意, 柯珂. 基于地震动强度随机场的同济大学校园建筑群损失概率评估. 建筑结构学报, 2025, 46(7): 22-33, 73.

## 文件结构

### 主程序文件
- `Main_1_EQrecords.m` - 地震动记录处理和台站分析
- `Main_2_IDA.m` - 增量动力分析
- `Main_3_Loss.m` - 单体建筑损失分析
- `Main_4_SpatialCov.m` - 空间相关性分析
- `Main_5_RegionalLossSim.m` - 区域地震损失模拟

### 数据文件夹
- `Data/` - 包含地震动记录、建筑信息、OSM地图数据等
- `results/` - 存储各阶段计算结果
- `Figures/` - 生成的图表和可视化结果

### 源代码文件夹
- `src/` - 核心函数和第三方工具库

## 使用说明

### 环境要求
- MATLAB R2019b或更高版本
- 需要安装的工具箱：
  - Statistics and Machine Learning Toolbox
  - Optimization Toolbox
  - Mapping Toolbox (可选)

### 运行步骤
1. **地震动数据处理**
   ```matlab
   run Main_1_EQrecords.m
   ```
   处理PEER NGA数据库中的历史地震记录，生成台站位置图和地震动时程文件。

2. **增量动力分析**
   ```matlab
   run Main_2_IDA.m
   ```
   对校园内5栋建筑（北楼、图书馆、旭日楼、逸夫楼、综合楼）进行IDA分析，建立易损性曲线。

3. **损失评估**
   ```matlab
   run Main_3_Loss.m
   ```
   使用Pelicun框架进行概率损失评估，生成损失曲线和维修费用/时间分析。

4. **空间相关性分析**
   ```matlab
   run Main_4_SpatialCov.m
   ```
   分析地震动强度参数的空间相关性，建立相关性模型。

5. **区域损失模拟**
   ```matlab
   run Main_5_RegionalLossSim.m
   ```
   基于地震动强度随机场进行区域损失蒙特卡洛模拟。


