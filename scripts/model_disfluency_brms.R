# scripts/model_disfluency_brms.R
# Bayesian hierarchical model for disfluency counts (Negative Binomial with offset)
suppressPackageStartupMessages({
  library(brms)
  library(readr)
  library(dplyr)
  library(emmeans)
})

# --- Load data ---
df <- read_csv("schema/df_analysis.csv", show_col_types = FALSE)

# --- Contrast coding (±0.5) ---
to_c <- function(x, pos, neg) ifelse(x == pos, 0.5, -0.5)

df <- df %>%
  mutate(
    group      = to_c(group, "student", "pro"),
    switch     = to_c(switch, "within", "between"),
    block      = to_c(block, "single", "mixed"),
    direction  = to_c(direction, "L1L2", "L2L1"),
    congruency = to_c(congruency, "inc", "cong")
  )

# --- Model ---
bf_main <- bf(
  y_disfl_total ~ offset(log(exposure_words)) +
    group * switch +
    group * direction +
    block * switch +
    congruency +
    WMC_z + speech_rate_src + trial_index +
    (1 + switch + block + direction + congruency | interpreter_id) +
    (1 | item_id),
  family = negbinomial(link = "log")
)

priors <- c(
  set_prior("normal(0, 0.5)", class = "b"),
  set_prior("student_t(3, 0, 2)", class = "Intercept"),
  set_prior("student_t(3, 0, 0.5)", class = "sd"),
  set_prior("lkj(2)", class = "cor"),
  set_prior("exponential(1)", class = "shape")
)

fit <- brm(
  bf_main,
  data = df,
  prior = priors,
  chains = 4, iter = 4000, cores = 4,
  control = list(adapt_delta = 0.95, max_treedepth = 12)
)

# --- Summaries ---
print(summary(fit))
# IRRs
irr <- exp(fixef(fit)[, "Estimate"])
print(irr)

# Contrasts: switch by group
emm <- emmeans(fit, ~ switch | group, type = "link")
print(contrast(emm, "revpairwise"))

# Posterior predictive checks
pp_check(fit, ndraws = 100)

# Save model
saveRDS(fit, file = "derivatives/model_disfluency_brms.rds")
