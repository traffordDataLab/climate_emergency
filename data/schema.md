| Name | Description | Data type | Value constraints |   Example(s) |
|:--|:--|:--|:--|:--|
| area_code | ONS code for the local authority | String | Local authorities in the UK | E08000009 |
| area_name | ONS name for the local authority | String | Local authorities in the UK | Trafford |
| indicator | Concise description of dataset | string | No reference to measure | Detached houses | 
| period | The period of time the data refer to | String | Date: YYYY-MM or YYYY-MM-DD |  2019-01 or 2018-12-31 |
| |  | | Single year: YYYY | 2019 |
| |  | | Financial/education year: YYYY/YY | 2017/18 | 
| |  | | Date range: YYYY to YYYY | 2016 to 2019 |
| measure | How values are expressed | String | Maintain consistency of terms | Count, Percentage, Rate, Median, Ratio |
| unit | The unit of measurement | String | Maintain consistency of terms | Households, Persons, Crimes |
| value | A numeric value  | Integer / Double |  Round value to one decimal digit | 3.4 |
| group | A grouping variable  | String |  | Female, Male |