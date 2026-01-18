return {
  {
    "folke/snacks.nvim",
    opts = {
      picker = {
        sources = {
          files = {
            hidden = true,  -- Mostrar archivos ocultos al buscar archivos
            ignored = true, -- Incluir archivos en .gitignore al buscar
          },
          explorer = {
            hidden = true,  -- Mostrar archivos ocultos en el explorador (Space+e)
            ignored = true, -- Mostrar archivos ignorados por git
          },
        },
      },
    },
  },
}
