# Visualização: Popularidade e avaliação de animes no MyAnimeList
# Bubble scatter plot:
# X = ano de lançamento
# Y = score médio
# tamanho = members
# cor = década

r_minor <- strsplit(R.version$minor, ".", fixed = TRUE)[[1]][1]
user_lib <- file.path(Sys.getenv("LOCALAPPDATA"), "R", "win-library", paste(R.version$major, r_minor, sep = "."))

dir.create(user_lib, recursive = TRUE, showWarnings = FALSE)
.libPaths(c(user_lib, .libPaths()))

packages <- c("ggplot2", "ggrepel", "scales")

for (pkg in packages) {
  if (!requireNamespace(pkg, quietly = TRUE)) {
    install.packages(pkg, lib = user_lib, repos = "https://cloud.r-project.org")
  }
}

library(ggplot2)
library(ggrepel)
library(scales)

dir.create("imagens", showWarnings = FALSE)

animes <- read.csv("dados/animes_mal.csv", stringsAsFactors = FALSE)

animes$rank <- as.numeric(animes$rank)
animes$year <- as.numeric(animes$year)
animes$score <- as.numeric(animes$score)
animes$members <- as.numeric(animes$members)

animes_plot <- subset(
  animes,
  !is.na(year) &
    !is.na(score) &
    !is.na(members) &
    members > 0
)

animes_plot$decade_start <- floor(animes_plot$year / 10) * 10
animes_plot$decade <- paste0(animes_plot$decade_start, "s")

# Agora todos os 50 animes recebem rótulo.
labels <- animes_plot

plot_animes <- ggplot(
  animes_plot,
  aes(x = year, y = score)
) +
  geom_point(
    aes(size = members, color = decade),
    alpha = 0.42
  ) +
  geom_text_repel(
    data = labels,
    aes(label = title),
    size = 2.8,
    min.segment.length = 0,
    box.padding = 0.55,
    point.padding = 0,
    max.overlaps = Inf,
    force = 2.5,
    force_pull = 0.4,
    seed = 42,
    arrow = grid::arrow(length = grid::unit(0.012, "npc"), type = "closed"),
    segment.curvature = 0,
    segment.ncp = 1,
    show.legend = FALSE
  ) +
  scale_size_continuous(
    range = c(4, 34),
    breaks = c(2000000, 3000000, 4000000),
    labels = label_number(scale = 1e-6, suffix = "M"),
    name = "Membros"
  ) +
  scale_x_continuous(
    breaks = seq(1995, 2025, by = 5),
    limits = c(1994, 2023)
  ) +
  scale_y_continuous(
    breaks = seq(6.5, 9.2, by = 0.5),
    limits = c(6.45, 9.3)
  ) +
  labs(
    title = "Popularidade e avaliação de animes no MyAnimeList",
    subtitle = "Top 50 por popularidade: bolhas maiores indicam mais membros; altura indica score médio",
    x = "Ano de lançamento",
    y = "Score médio no MyAnimeList",
    color = "Década",
    caption = "Fonte: MyAnimeList — Top Anime by Popularity. \"Members\" representa usuários que adicionaram o anime à lista em algum status."
  ) +
  theme_minimal(base_size = 14) +
  theme(
    plot.title = element_text(face = "bold", size = 20),
    plot.subtitle = element_text(size = 11.5),
    plot.caption = element_text(size = 9, color = "gray35"),
    legend.position = "right",
    panel.grid.minor = element_blank()
  )

ggsave(
  filename = "imagens/animes_score_members_ano.png",
  plot = plot_animes,
  width = 15,
  height = 8.5,
  dpi = 200
)

message("Imagem gerada em: imagens/animes_score_members_ano.png")