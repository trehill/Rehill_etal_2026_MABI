
library(here)
library(dplyr)
library(ggplot2)
library(vegan)
library(readr)
library(lubridate)
library(stringr)

urchin_data <- read.csv("/Users/tessarehill/Dropbox/MSc/Exclosures/raw_data/urchin_monitoring_transects.csv")

kelp_data <- read.csv("/Users/tessarehill/Dropbox/MSc/Exclosures/raw_data/green_gravel_monitoring.csv")

#read in monitoring_periods, manually entered time periods to be assessed for each associated month 
monitoring_periods<- read.csv("/Users/tessarehill/Dropbox/MSc/Exclosures/processed_data/ENV/monitoring_periods.csv")

#DATE ##################################
#create a new column called 'month' 
kelp_data$date <- as.Date(kelp_data$date, format="%Y-%m-%d")
kelp_data$month <- month(kelp_data$date, label = TRUE, abbr = FALSE)

#KELP TOTAL LENGTHS ###################
#ensure kelp lengths are numeric
kelp_data$kelp_total1 <- as.numeric(kelp_data$kelp_total1)
kelp_data$kelp_total2 <- as.numeric(kelp_data$kelp_total2)
kelp_data$kelp_total3 <- as.numeric(kelp_data$kelp_total3)
kelp_data$kelp_total4 <- as.numeric(kelp_data$kelp_total4)
kelp_data$kelp_total5 <- as.numeric(kelp_data$kelp_total5)

kelp_data <- kelp_data %>% #make NA into 0 
  mutate_at(vars(kelp_total1, kelp_total2, kelp_total3, kelp_total4, kelp_total5, n_gravel, n_kelp_gravel), ~replace(., is.na(.), 0))


#KELP PLOT_IDs ########################
#checking plot_id, should start with C or U, followed by S or L
unique(kelp_data$plot_id)

#need to change the errors (#lu3, lc1, sc2, su2, lu1)
#ensure the required pattern is applied to the 'plot_id' column
kelp_data$plot_id <- gsub("^(.*)(.*)(.*)$", "\\1\\2\\3", kelp_data$plot_id)

#define a function to correct the plot_id format
correct_plot_id <- function(plot_id) {
  # Extract the valid characters using regular expressions
  matches <- regmatches(plot_id, regexec("([cu])([ls])([123])", plot_id))
  
  # If matches are found, reconstruct the correct plot_id
  if (length(matches[[1]]) == 4) {
    return(paste0(matches[[1]][2], matches[[1]][3], matches[[1]][4]))
  } else {
    return(NA) # Assign NA if the pattern cannot be corrected
  }
}

#apply the function to the plot_id column
kelp_data$plot_id <- sapply(kelp_data$plot_id, correct_plot_id)

#remove rows with NA in plot_id
kelp_data <- kelp_data[!is.na(kelp_data$plot_id), ]

unique(kelp_data$plot_id)

#KELP TREATMENT ######################
#if plot_id starts with c = caged, u = uncaged 
kelp_data$treatment <- ifelse(substr(kelp_data$plot_id, 1, 1) == 'c', 'caged', #creates new column called treatment
                              ifelse(substr(kelp_data$plot_id, 1, 1) == 'u', 'open', NA))

#if plot_id has second letter l = large, s = small 
kelp_data$gravel_size <- ifelse(substr(kelp_data$plot_id, 2, 2) == 'l', 'large', #creates new column called gravel size 
                                ifelse(substr(kelp_data$plot_id, 2, 2) == 's', 'small', NA))

#make new column called plot that removes caged/uncaged letter from plot_id column 
kelp_data <- kelp_data %>%
  mutate(plot = substr(plot_id, 2, nchar(plot_id)))

#SITE ########
# Replace "Ellis_S" with "Ellis S" and "Ellis_N" with "Ellis N"
kelp_data$site <- gsub("Ellis_S", "Ellis S", kelp_data$site)
kelp_data$site <- gsub("Ellis_N", "Ellis N", kelp_data$site)

unique(kelp_data$site)

#PERCENT KELP ##########
#make a new column to determine the percentage of gravel with kelp 
#perc_kelp = n_kelp_gravel/n_gravel x 100 
#if n_gravel is equal to zero, the result is 0 
kelp_data$kelp_survival <- ifelse(kelp_data$n_gravel == 0, 0, (kelp_data$n_kelp_gravel / kelp_data$n_gravel) * 100)

kelp_filtered <- kelp_data[kelp_data$kelp_survival > 100, ] #make sure doesn't exceed 100

#are there instances where n_kelp > n_gravel, if NA, n_gravel was taken from the most recent monitoring
# Create a new dataframe with rows where n_kelp_gravel > n_gravel
kelp_data_filtered <- kelp_data[kelp_data$n_kelp_gravel > kelp_data$n_gravel, ]

#PLOT URCHIN DENSITY #########
#make a new column that describes urchin density per m^2
#for open plots = total number urchins / 1 m^2 
#for caged plots = total number urchins / 4.5 m^2 
kelp_data$n_gu_side <- as.numeric(kelp_data$n_gu_side)
kelp_data <- kelp_data %>%
  mutate(
    total_urchins = rowSums(across(c(n_ru, n_gu, n_pu, n_ru_side, n_pu_side, n_gu_side)), na.rm = TRUE),
    urchin_density = case_when(
      treatment == "caged" ~ total_urchins / 4.5,
      treatment == "open" ~ total_urchins / 1,
      TRUE ~ NA_real_
    )
  )

#GRAZER DENSITY #############
#make a new column that describes grazer density per m^2 
#grazers ONLY include urchins, turban snails and abalone 
kelp_data <- kelp_data %>%
  mutate(
    total_grazers = rowSums(across(c(n_ru, n_gu, n_pu, n_ru_side, n_pu_side, n_gu_side, n_ab, n_ts)), na.rm = TRUE),
    grazer_density = case_when(
      treatment == "caged" ~ total_grazers / 4.5,
      treatment == "open" ~ total_grazers / 1,
      TRUE ~ NA_real_
    )
  )

kelp_data <- kelp_data %>%
  mutate(
    total_ts = n_ts,
    ts_density = case_when(
      treatment == "caged" ~ total_ts / 4.5,
      treatment == "open" ~ total_ts / 1,
      TRUE ~ NA_real_
    )
  )

#remove leading/trailing spaces from the 'site' columns in both datasets
kelp_data$site <- stringr::str_trim(kelp_data$site)

#ensure there are 12 plots per month in dataset 
#summarize the data to count unique plot_id per month and site
unique_plot_counts <- kelp_data %>%
  group_by(month, site) %>%
  summarize(unique_plot_count = n_distinct(plot_id), .groups = "drop")

unique_plot_counts #ensure 12 plots per month

View(unique_plot_counts) #duplicated data at TR and EK 

#KELP GROWTH ###############################
#sum kelp growth per plot 

#growth is TOTAL growth (irrelevant of individual)
kelp_data$kelp_growth <- rowSums(kelp_data[, c("kelp_total1", "kelp_total2", "kelp_total3", "kelp_total4", "kelp_total5")])

#kelp growth of zero should be NA 
kelp_data <- kelp_data %>%
  mutate(kelp_growth = ifelse(kelp_growth == 0, NA, kelp_growth))

#write.csv(kelp_data, "/Users/tessarehill/Dropbox/MSc/Grazer_exclusion/processed_data/cleaned_green_gravel_monitoring_Aug.csv", row.names = FALSE)

#remove August month 
#kelp_data <- kelp_data %>%
#  filter(!month %in% c("August"))


#save the cleaned dataframe to a new CSV file
#write.csv(kelp_data, "/Users/tessarehill/Dropbox/MSc/Grazer_exclusion/processed_data/cleaned_green_gravel_monitoring.csv", row.names = FALSE)

#plot august data
plots <- kelp_data

plots_august <- plots %>%
  filter(month == "August")

#KELP SURVIVAL ###########
#sumamrize urchin density by site and month and treatment
survival_summary <- plots_august %>%
  group_by(treatment, site, month) %>%
  summarise(
    mean_survival = mean(kelp_survival, na.rm = TRUE),
    sd_survival = sd(kelp_survival, na.rm = TRUE),
    n = n(),
    se_survival = sd_survival / sqrt(n),
    .groups = "drop"
  )

survival_summary$site <- factor(survival_summary$site, levels = c("Nanat", "Ellis S", "Ellis N", "Dixon", "Ed King", "Taylor"))
survival_summary$month <- factor(survival_summary$month, levels = c("April", "May", "June", "August"))

plot <- ggplot(survival_summary, aes(x = site, y = mean_survival, pattern = treatment)) +
  geom_bar_pattern(
    stat = "identity",
    position = position_dodge(width = 0.7),
    width = 0.7,
    fill = "white",
    color = "black",
    pattern_density = 0.05,
    pattern_spacing = 0.05,
    pattern_fill = "black",
    pattern_color = "black",
    pattern_angle = 45,
    pattern_alpha = 1
  ) +
  geom_errorbar(
    aes(ymin = mean_survival - se_survival,
        ymax = mean_survival + se_survival),
    position = position_dodge(width = 0.7),
    width = 0.2,
    color = "black"
  ) +
  facet_wrap(~ month, scales = "fixed", ncol = 1) +
  labs(
    x = "Site",
    y = "Kelp Survival (%)",
    fill = "Treatment"
  ) +
  scale_pattern_manual(values = c("caged" = "crosshatch", "open" = "none")) +
  scale_y_continuous(limits = c(0, 100)) +
  theme_minimal() +
  theme(
    axis.line = element_line(color = "black"),
    axis.text.x = element_text(angle = 45, hjust = 1, size = 30),
    axis.text.y = element_text(size = 40),
    axis.title.x = element_text(size = 40, face = 'bold'),
    axis.title.y = element_text(size = 40, face = 'bold'),
    panel.grid.major.x = element_blank(),
    strip.text = element_text(size = 40)
  )


# Print plot
print(plot)

#save plot
ggsave("/Users/tessarehill/Dropbox/MSc/Exclosures/plots/kelp_survival/bwsurvival_site_august.png", plot = plot,  width = 15, height = 10, dpi = 300)

growth_plots <-  plots[!is.na(plots$kelp_growth), ]

growth_summary <- growth_plots %>%
  group_by(treatment, site, month) %>%
  summarise(
    mean_growth = mean(kelp_growth, na.rm = TRUE),
    sd_growth = sd(kelp_growth, na.rm = TRUE),
    n = n(),
    se_growth = sd_growth / sqrt(n),
    .groups = "drop"
  )

growth_summary$site <- factor(growth_summary$site, levels = c("Nanat", "Ellis S", "Ellis N", "Dixon", "Ed King", "Taylor"))
growth_summary$month <- factor(growth_summary$month, levels = c("April", "May", "June", "August"))

plot <- ggplot(growth_summary, aes(x = site, y = mean_growth, pattern = treatment)) +
  geom_bar_pattern(
    stat = "identity",
    position = position_dodge(width = 0.7),
    width = 0.7,
    fill = "white",
    color = "black",
    pattern_density = 0.05,
    pattern_spacing = 0.05,
    pattern_fill = "black",
    pattern_color = "black",
    pattern_angle = 45,
    pattern_alpha = 1
  ) +
  geom_errorbar(
    aes(ymin = mean_growth - se_growth,
        ymax = mean_growth + se_growth),
    position = position_dodge(width = 0.7),
    width = 0.2,
    color = "black"
  ) +
  facet_wrap(~ month, scales = "free_y", ncol = 1) +
  labs(
    x = "Site",
    y = "Kelp Length (cm)",
    fill = "Treatment"
  ) +
  scale_pattern_manual(values = c("caged" = "crosshatch", "open" = "none")) +
  theme_minimal() +
  theme(
    axis.line = element_line(color = "black"),
    axis.text.x = element_text(angle = 45, hjust = 1, size = 30),
    axis.text.y = element_text(size = 30),
    axis.title.x = element_text(size = 40, face = 'bold'),
    axis.title.y = element_text(size = 40, face = 'bold'),
    panel.grid.major.x = element_blank(),
    strip.text = element_text(size = 40)
  )

# Display the plot
print(plot)

ggsave("/Users/tessarehill/Dropbox/MSc/Exclosures/plots/kelp_growth/bwgrowth_site_august.png", plot = plot, width = 15, height = 10, dpi = 300)
