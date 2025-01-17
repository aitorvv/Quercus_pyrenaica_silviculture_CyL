# *Quercus pyrenaica* silviculture in Castilla and Leon

*A repository with the original data, code and results of: **Silviculture alternatives evaluation for managing complex Quercus pyrenaica stands***

---

# Silviculture alternatives evaluation for managing complex *Quercus pyrenaica* stands

:open_file_folder: Repository DOI: [![DOI](https://zenodo.org/badge/DOI/10.5281/zenodo.14680267.svg)](https://doi.org/10.5281/zenodo.14680267)

📜 Manuscript DOI: <!-- https://doi.org/10.1016/j.ecolmodel.2024.110912 -->

---

## :book: Abstract

Pyrenean oak (*Quercus pyrenaica* Willd.) is a Mediterranean forest species endemic to the Iberian Peninsula and is highly expanded in the Castilla and León region (Spain). Despite its potential in the wood industry, traditional uses and the lack of profitable management guidelines deteriorated its stands status, reducing the attention of owners and managers towards this species. This study explores the effects of different silvicultural scenarios on Pyrenean oak stands in transforming regular coppice stands into irregular high forests and in managing irregular stands based on a sustainable approach. Considering different criteria to ensure satisfactory forest conditions, predictions about key forest characteristics and various wood products were estimated to attract industry attention to the species’ potential. A clear need to adapt thinning periodicity, intensity, and criteria according to the local conditions of the stand was identified, requiring managers with expertise in irregular forest management. While numerical predictions may be biased, the trends observed under different management styles allow us to rank them according to the management objectives. Future work should aim to increase knowledge of irregular stand management and develop accurate tools to support managers on decision-making processes.

---

## :file_folder: Repository Contents

- :floppy_disk: **1_data**:
    
    - :sunny: climate data obtained from [WorldClim data](https://www.worldclim.org/data/index.html)
        
    - :deciduous_tree: tree and plot inventory data used on each case study is available in *.xlsx* format


- :seedling: **2_simanfor** contains inputs and outputs (Spanish and English) for all the simulations developed with [SIMANFOR](www.simanfor.es). Check out them! There are a lot of metrics unexplored in this paper :wood: :maple_leaf:

- :computer: **3_code**:


| Script Name     | Purpose               | Input                    | Output                   |
|-----------------|-----------------------|--------------------------|--------------------------|
| `0_dbh_distribution_inventory.R` | Uses the original inventories to graph its diameter classes distribution | [1_data](https://github.com/aitorvv/Quercus_pyrenaica_silviculture_CyL/tree/main/1_data), [WorldClim data](https://www.worldclim.org/data/index.html) | [0_dbh_distribution_inventory](https://github.com/aitorvv/Quercus_pyrenaica_silviculture_CyL/tree/main/4_figures/0_dbh_distribution_inventory.png)
| `1_dbh_distribution_simulation.R`| Uses the SIMANFOR simulation results to graph its diameter classes distribution | [2_simanfor/output](https://github.com/aitorvv/Quercus_pyrenaica_silviculture_CyL/tree/main/2_simanfor/output_ES) | [1_dbh_distribution_simulation_1](https://github.com/aitorvv/Quercus_pyrenaica_silviculture_CyL/tree/main/4_figures/1_dbh_distribution_simulation_1.png) [1_dbh_distribution_simulation_2](https://github.com/aitorvv/Quercus_pyrenaica_silviculture_CyL/tree/main/4_figures/1_dbh_distribution_simulation_2.png) |
| `2.0_group_simanfor_data.R` | Functions created to group SIMANFOR results in a format to graph them | - | - |
| `2.1_graph_templates.R` | Functions created with templates to graph SIMANFOR results | - | - |
| `2.2_graph_results.R` | Code that uses both previous scripts to manage and graph SIMANFOR results  | [2_simanfor/output](https://github.com/aitorvv/Quercus_pyrenaica_silviculture_CyL/tree/main/2_simanfor/output_ES) | [SG02](https://github.com/aitorvv/Quercus_pyrenaica_silviculture_CyL/tree/main/4_figures/SG), [SO02](https://github.com/aitorvv/Quercus_pyrenaica_silviculture_CyL/tree/main/4_figures/SO), [SG02*](https://github.com/aitorvv/Quercus_pyrenaica_silviculture_CyL/tree/main/4_figures/SG_irregular), [SO02*](https://github.com/aitorvv/Quercus_pyrenaica_silviculture_CyL/tree/main/4_figures/SO_irregular), and[grouped_figures](https://github.com/aitorvv/Quercus_pyrenaica_silviculture_CyL/tree/main/4_figures/grouped_figures) graphs |
| `3_summary_scenarios.R` | Code to summarize SIMANFOR silvicultural paths used in this study | [2_simanfor/output](https://github.com/aitorvv/Quercus_pyrenaica_silviculture_CyL/tree/main/2_simanfor/output_EN) | [3_summary_scenarios](https://github.com/aitorvv/Quercus_pyrenaica_silviculture_CyL/tree/main/4_figures/3_summary_scenarios.csv) |

- :bar_chart: **4_figures**: graphs and figures used on the article

- :books: **5_bibliography**: recopilation of all the references used on the article

---

## :books: <img src="https://avatars.githubusercontent.com/u/111344993?s=200&v=4" alt="simanfor_logo" width="30">    Additional Information

To gain a better understanding of how SIMANFOR works, you can explore its [website](https://www.simanfor.es/), [GitHub repository](https://github.com/simanfor), [manual](https://github.com/simanfor/manual), [YouTube playlist](https://www.youtube.com/playlist?list=PLsdzTKpJZZa7vn5zGpn07-bd0Nce-fMhJ) or even the [last paper](https://doi.org/10.1016/j.ecolmodel.2024.110912). 

---

## ℹ License

The content of this repository is under the [MIT license](./LICENSE).

---

## 🔗 About the authors


#### Aitor Vázquez Veloso:

[![](https://github.com/aitorvv.png?size=50)](https://github.com/aitorvv) \\ 
[ORCID](https://orcid.org/0000-0003-0227-506X) \\
[Researchgate](https://www.researchgate.net/profile/Aitor_Vazquez_Veloso) \\
[LinkedIn](https://www.linkedin.com/in/aitorvazquezveloso/) \\
[Twitter](https://twitter.com/aitorvv) \\
[UVa](https://portaldelaciencia.uva.es/investigadores/178830/detalle)

#### Angel Cristóbal Ordóñez Alonso:

[![](https://github.com/acristo.png?size=50)](https://github.com/acristo) \\
[ORCID](https://orcid.org/0000-0001-5354-3760) \\
[Researchgate](https://www.researchgate.net/profile/Cristobal-Ordonez-Alonso) \\
[LinkedIn](https://www.linkedin.com/in/cristobal-ordonez-b6a97244/) \\
[Twitter](https://twitter.com/OrdonezAC) \\
[UVa](https://portaldelaciencia.uva.es/investigadores/181312/detalle)

#### Felipe Bravo Oviedo:

[![](https://github.com/Felipe-Bravo.png?size=50)](https://github.com/Felipe-Bravo) \\
[ORCID](https://orcid.org/0000-0001-7348-6695) \\
[Researchgate](https://www.researchgate.net/profile/Felipe-Bravo-11) \\
[LinkedIn](https://www.linkedin.com/in/felipebravooviedo) \\
[Twitter](https://twitter.com/fbravo_SFM) \\
[UVa](https://portaldelaciencia.uva.es/investigadores/181874/detalle)

---

<div style="text-align: center;">

[*Quercus pyrenaica* silviculture in Castilla and Leon](https://github.com/aitorvv/Quercus_pyrenaica_silviculture_CyL) 

</div>