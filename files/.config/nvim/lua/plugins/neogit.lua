local present, neogit = pcall(require, "neogit")

if not present then
  return
end

local options = {
  integrations = {
    diffview = false
  }
}

neogit.setup(options)
