# Wage theft data analysis

# levels 3 and 4, third and fourth digit of naic_cd

# total outcome var (backwages): bw_atp_amt
# number of employees: ee_atp_cnt
# per emplyoyee can be calc by bw_atp_amt/ee_atp_cnt

# end of violation is usually beginning of investigation: findings_end
# 2008 - 2014 will be the full years


# law code (e.g. min wage, overtime)- flsa_violtn
# worth investigating specifically - min wage (more serious problems): flsa_mw_bw_atp_amt
# number of emplyees paid out to for min wage viol: flsa_ee_atp_cnt

# naic_cd2 ,3 ,4


# join zipcodes to counties to FIPS (FIPS is ultimate goal, b/c geolocation best w FIPS)

# egregiousness - total size or total per emp
# vulnerability - min wage focused, low wage counties

# Questions: Industries (at each naic level 2,3,4,5) ranked by:
# 1. total back wages (egregiousness focus)
# 2. back wages per worker
# 3. total minimum-wage-violation back wages (vulnerability focus)
# 4. min-wage-bw per worker

# Note: check for outliers, present the data both with and without

# 5. Check for correlations with demographic data, by industry and county
# 6. Find unusual data points (high or low) to help find possible trouble spots
# Particulary places that seem oddly low
# Consider that most egregious cases may not have been identified yet


# 7. Save results in a format which can be managed and added to consistently going forward into the future (perhaps an online SQL database)

# Step 1: load data and packages
# library("readr")
library("dplyr")
violations_path = "/Users/nathanhelm-burger/Documents/Dropbox/datadive_wagetheft/data/processedWhdData/"
#df = data.frame(read_csv(paste0(violations_path, "whd_whisard.naicNumericLevels.csv")))
df = read.csv(paste0(violations_path, "whd_whisard.naicNumericLevels.csv"))
#colnames(df)
df_subset = df[c(1:10, 12:14, 111:116)]
df_subset = cbind(df_subset, df$flsa_bw_atp_amt, df$flsa_ee_atp_cnt)
dim(df_subset)
#df_subset = na.omit(df_subset)
#summary(df_subset)
#colnames(df_subset)
naic_level_names = lapply(colnames(df_subset[14:19]), as.symbol)
colnames(df_subset)[20] = "flsa_mw_bw_atp_amt"
colnames(df_subset)[21] = "flsa_ee_atp_cnt"
# Loop to create and write to csv each naic level grouping

for(naic_lvl in 2:5){
  # Total Backwage Info: bw_atp_amt, ee_atp_cnt
  # Minimum wage info: flsa_mw_bw_atp_amt, flsa_ee_atp_cnt
  df_grouped = df_subset %>% group_by_(.dots=naic_level_names[naic_lvl])
  sum_df_byNaic = summarize(df_grouped,
                            industries = n(),
                            total_industry_bw = sum(bw_atp_amt, na.rm = TRUE),
                            avg_industry_bw = sum(bw_atp_amt, na.rm = TRUE)/n(),
                            bw_per_emp = sum(bw_atp_amt, na.rm = TRUE)/sum(ee_atp_cnt, na.rm = TRUE),
                            total_industry_bw_mw = sum(flsa_mw_bw_atp_amt, na.rm = TRUE),
                            avg_industry_bw_mw = sum(flsa_mw_bw_atp_amt, na.rm = TRUE)/n(),
                            bw_mw_per_emp = sum(flsa_mw_bw_atp_amt, na.rm = TRUE)/sum(flsa_ee_atp_cnt, na.rm = TRUE))

  filename = paste0("df_grouped_byNaic", as.character(naic_lvl))
  filename = paste0(filename, ".csv")
  print(filename)
  write.csv(sum_df_byNaic, filename, row.names = FALSE)
}

# open csv, join the names, write updated csv
naic_name_df = read.csv("2012_NAICS_Structure_FINAL.csv")

for(naic_lvl in 2:5){
  filename = filename = paste0("df_grouped_byNaic", as.character(naic_lvl))
  filename = paste0(filename, ".csv")
  temp_df = read.csv(filename)
  colnames(temp_df)[1] = "NAICS.Code"
  # print(colnames(temp_df))
  temp_df = left_join(temp_df, naic_name_df,
            by=c("NAICS.Code" = "NAICS.Code"))

  write.csv(temp_df, filename, row.names = FALSE)
}

dfby2 = read.csv("df_grouped_byNaic2.csv")
dfby3 = read.csv("df_grouped_byNaic2.csv")


# Demographic data and industry data

# Load and join industry data
industry_df1 = read.csv("/Users/nathanhelm-burger/Documents/Dropbox/datadive_wagetheft/data/census/County Business Patterns/CountyBusinessPatternsCaliforniaNAICS2.csv")
#industry_df2 = read.csv("/Users/nathanhelm-burger/Documents/Dropbox/datadive_wagetheft/data/census/County Business Patterns/CountyBusinessPatternsCaliforniaNAICS3.csv")


for(name_col in 5:9){
  colnames(industry_df1)[name_col] = paste0("Industry_NAICS2_", colnames(industry_df1)[name_col])
}
# for(name_col in 5:9){
#   colnames(industry_df2)[name_col] = paste0("Industry_NAICS3_", colnames(industry_df2)[name_col])
# }

# industry_df_full = full_join(industry_df1, industry_df2)
# colnames(industry_df1)
# View(industry_df_full)

demg_path = "/Users/nathanhelm-burger/Documents/Dropbox/datadive_wagetheft/data/census/"

demg1 = read.csv(paste0(demg_path, "county_wide_demographic.csv"), stringsAsFactors = FALSE)
colnames(demg1)
colnames(demg1)[1] = "county"
demg1['STATE'] = NULL
demg1["YEAR"] = NULL
demg1['COUNTY'] = NULL
head(demg1)
dim(demg1)
# industry_df_full$STATE = 6
# demg1$County = as.factor(demg1$County)
#california_demg = demg1[demg1['STATE']==6,]
#dim(california_demg)
#dim(industry_df_full)
#california_demg$County = as.factor(california_demg$County)
#setdiff(california_demg$County, industry_df_full$County)
# industry_demg = full_join(industry_df_full, demg1)
# dim(industry_demg)
# dim(industry_df_full)
#dim(california_demg)

# colnames(industry_demg)[4]
# colnames(industry_demg)[10]
# colnames(industry_demg)[4] = "naic_cd_lvl2"
# colnames(industry_demg)[10] = "naic_cd_lvl3"
# colnames(industry_demg)[2] = "State"
# colnames(industry_demg)[1] = "st_cd"
# colnames(industry_demg)[c(1,4,10)] %in% colnames(df)

#write.csv(industry_demg, paste0(violations_path,"industry_and_demographics.csv"), row.names = FALSE)

#industry_demg = read.csv(paste0(violations_path, "industry_and_demographics.csv"))
#str(industry_demg$naic_cd_lvl3)
#industry_demg$naic_cd_lvl3 = as.factor(industry_demg$naic_cd_lvl3)

colnames(industry_df1)[4] = "naic_cd_lvl2"
colnames(industry_df1)[1] = 'st_cd'
colnames(industry_df1)[3] = "county"
industry_df1["State.Name"] = NULL
industry_df1["Industry_NAICS_Industry"] = NULL
head(df$st_cd)
colnames(industry_df1)

dropbox_path = "/Users/nathanhelm-burger/Documents/Dropbox/datadive_wagetheft/data/processedWhdData/"
joined_county = read.csv(paste0(dropbox_path,"whd_whisard.naicHumanReadableLevels_v3_countyfips_2_Plus_Santa_Clara.csv"))
dim(joined_county)
join1_df = merge(joined_county, industry_df1, all.x = TRUE, all.y = FALSE, sort = FALSE)
colnames(join1_df)
dim(join1_df)
write.csv(join1_df, "join1.csv", row.names = FALSE)
join1_df = read.csv("join1.csv", stringsAsFactors = FALSE)
str(join1_df)
str(demg1)
library("dplyr")
join2_df = left_join(join1_df, demg1, by = c("county"))
dim(join2_df)

violations_path = "/Users/nathanhelm-burger/Documents/Dropbox/datadive_wagetheft/data/processedWhdData/"
write.csv(join2_df, paste0(violations_path, "whd_demographic_industry_violations_naicNumericLevels.csv"), row.names = FALSE)
full_df = read.csv(paste0(violations_path, "whd_demographic_industry_violations_naicNumericLevels.csv"), stringsAsFactors = FALSE)


#caret utility function
library('caret')
caret_reg = function(x, y, method, grid, ...) {
  set.seed(1)
  control = trainControl(method="repeatedcv", repeats=1,
                         number=2, verboseIter=TRUE)
  train(x=x, y=y, method=method, tuneGrid=grid,
        trControl=control, metric="RMSE",
        preProcess=c("center", "scale"), ...)
}

forest_caret = function(df, target) {
  # can search a set of mtry values in the mtry = c()
  forest_grid = data.frame(mtry = c(floor(sqrt(ncol(df)))))
  forest_model = caret_reg(x=df,
                           y=target,
                           method = 'ranger',
                           grid = forest_grid,
                           importance = 'impurity' )
  return(forest_model)
  #forest_model$results$RMSE
}

library('ranger')

# Find Predictions which are higher than true values.
# top 5 of each industry (NICS2) grouped by california_county
#
name_options = colnames(full_df)
chosen_cols = name_options[c(21, 112, 118:121, 137:206)]

min_wage_pred_df = joined_df[chosen_cols]

write.csv(min_wage_pred_df, "min_wage_pred_df.csv", row.names = FALSE)

min_wage_pred_df = read.csv("min_wage_pred_df.csv", stringsAsFactors = FALSE)

min_wage_pred_df = na.omit(min_wage_pred_df)
min_wage_pred_df = min_wage_pred_df[min_wage_pred_df$flsa_mw_bw_atp_amt != 0,]
dim(min_wage_pred_df)
summary(min_wage_pred_df)
min_wage_pred_df$X = NULL
pred_factors = min_wage_pred_df[,c(3, 5:ncol(min_wage_pred_df))]
str(min_wage_pred_df)
str(pred_factors)
dim(min_wage_pred_df)
dim(pred_factors)
# I think I need to adjust the forest_caret function to accept (not try to scale) categorical variables, or else make dummy variables if needed for non-ranger analyses
# min_wage_model = forest_caret(pred_factors, min_wage_pred_df$flsa_mw_bw_atp_amt)
# For testing accuracy of model:
grouping = sample(nrow(min_wage_pred_df), nrow(min_wage_pred_df), replace = FALSE)
min_wage_train = min_wage_pred_df[grouping %% 8,]
min_wage_test = min_wage_pred_df[min_wage_pred_df != min_wage_train,]
min_wage_ranger = ranger(dependent.variable.name = "flsa_mw_bw_atp_amt", data = min_wage_train)

# For making practical use model:
min_wage_ranger = ranger(dependent.variable.name = "flsa_mw_bw_atp_amt", data = min_wage_pred_df)

rmse = min_wage_model$results$RMSE
str(min_wage_model)
?ranger

# Make new dataframe: actual min wage violation, predicted min wage violation, difference (predicted-actual), county (group by county)
# Order dataframe by difference(predicted-actual) (after aggregate by county)
# Bar plot top 20 or so of these, as two bars per each county (one for actual, one for pred)
# min_wage_model$results$x
?predict.ranger
model_pred = predict(min_wage_model, min_wage_pred_df)
head(min_wage_pred_df[1:3], 190)
pred_df = cbind(min_wage_pred_df$flsa_mw_bw_atp_amt, model_pred)
head(pred_df, 40)
dim(pred_df)
summary(pred_df)
uhoh = df[df$flsa_mw_bw_atp_amt == 4351.10,]
head(uhoh[0:14])
dim(uhoh)
# Future directions
# We can assume that although we are only detecting a few examples for under-detected categories of violation, we are at least getting a few of the worst, thus we can fill out a set of imputed predicitons with the assumption of a multivariate normal distribution. Shape of distributions of well-detected categories (places, industries) can be used as approximations of shapes of under-detected categories (different places, same industries). Using these assumptions for our starting Bayesian Prior, we update on the info we find, then figure out where there "should" be larger violations.
