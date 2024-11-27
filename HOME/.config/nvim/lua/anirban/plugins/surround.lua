-- The way this works:
-- a) to surround quotes/tags: ys<motion><" or t>
--    1. add " around abc -> ysiw"
--    2. add tag around 10 lines -> on the 1st line: ys10jt<then type tag name>
-- b) deleting " -> ds"
-- c) changing " -> cs"
return {
  'kylechui/nvim-surround',
  event = { 'BufReadPre', 'BufNewFile' },
  version = '*', -- for stability, can be omitted to used main branch for latest updates
  config = true,
}
