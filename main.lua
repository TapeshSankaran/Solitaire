
-- Tapesh Sankaran
-- CMPM 121
-- 4-14-2025

--io.stdout:setvbuf("no")

local Deck = require "deck"
local Pile = require "pile"
local Card = require "card"

width  = 800
height = 600

mousePressed = false

solitaire = love.graphics.newImage("Sprites/Solitaire.png")

piles = {}
cardWaste = Pile:new(width*0.036, foundPosY + 125)
cardBuffer = {}

function love.load()
  love.window.setTitle("Solitaire")
  love.graphics.setDefaultFilter("nearest", "nearest")
  love.window.setMode(width, height)
  love.graphics.setBackgroundColor(.216, .396, .302)
  math.randomseed(os.time())
  --math.randomseed(3)
  
  
  deck = Deck:new(width*0.036, foundPosY)
  deck:shuffle()
  
  for i=1,7,1 do
    table.insert(piles, Pile:new(width*0.125+width*0.1*i, cardPosY))
  end
  
  for i, suit in ipairs(suits) do
    table.insert(piles, Pile:new(width*0.425+width*0.1*i, foundPosY))
    place = Card:new(
        0, 
        suit, 
        love.graphics.newImage("Sprites/" .. suit.s .. " " .. "A" .. ".png"), 
        true, 
        piles[#piles].position.x, 
        piles[#piles].position.y
    )
    place.draggable = false
    piles[#piles]:add(place)
  end
  for num, pile in ipairs(piles) do
    if num < 8 then
      for i=1,num,1 do
        if #pile.cards > 0 then
          pile.cards[#pile.cards].faceUp = false
        end
        pile:add(deck:deal())
      end
    end
  end
end

function love.update(dt)
  local mouseX, mouseY = love.mouse.getPosition()
  
  if draggableCard then
    draggableCard:update(dt, mouseX, mouseY)
  end
end

function love.draw()
  love.graphics.setColor(.18, .302, .255)
  love.graphics.rectangle("fill", 0, 0, width*0.15, height)
  love.graphics.rectangle("fill", 0, height*0.98, width, height*0.02)
  love.graphics.rectangle("fill", width*0.97, 0, width*0.03, height)      
  love.graphics.setColor(.14, .255, .230)
  love.graphics.rectangle("fill", 0, 0, width, height*0.24)    
  love.graphics.draw(emptyCard, deck.position.x, deck.position.y, 0, 1.5, 1.5)
  love.graphics.setColor(.216, .396, .302)
  love.graphics.draw(emptyCard, width*0.225, cardPosY, 0, 1.5, 1.5)
  love.graphics.draw(emptyCard, width*0.325, cardPosY, 0, 1.5, 1.5)
  love.graphics.draw(emptyCard, width*0.425, cardPosY, 0, 1.5, 1.5)
  love.graphics.draw(emptyCard, width*0.525, cardPosY, 0, 1.5, 1.5)
  love.graphics.draw(emptyCard, width*0.625, cardPosY, 0, 1.5, 1.5)
  love.graphics.draw(emptyCard, width*0.725, cardPosY, 0, 1.5, 1.5)
  love.graphics.draw(emptyCard, width*0.825, cardPosY, 0, 1.5, 1.5)
  love.graphics.setColor(1, 1, 1)
  love.graphics.draw(solitaire, width*0.3, height*0.05, 0, 0.3, 0.3)
  
  deck:draw()
  for i, pile in ipairs(piles) do
    if i < 8 then
      pile:draw()
    else
      pile:Fdraw()
    end
  end
  
  cardWaste:draw()
  
  love.graphics.setColor(1.00, 0.860, 0.25)
  if draggableCard ~= nil then
    draggableCard:draw()
  end
end

function love.mousepressed(x, y, button, istouch, presses)
  if button == 1 and draggableCard == nil then
    for _, card in ipairs(deck.cardTable) do
      if card.draggable and card.faceUp and card:isMouseOver(x, y) then
        draggableCard = card
        draggableCard:startDrag(x, y)
        break
      end
    end
  end
  
  if button == 1 and deck:isMouseOver(x, y) and not mousePressed then
    local cT = cardWaste.cards
    cardWaste.cards = {}
    for _, card in ipairs(cT) do
      card.position = Vector(-100, -100)
      card.draggable = false
      table.insert(cardBuffer, card)
    end
    for i=1,3,1 do
      local card = deck:deal()
      if card ~= nil then
        cardWaste:add(card)
        cardWaste.cards[#cardWaste.cards].draggable = false
      end
    end
    if #cardWaste.cards == 0 then
      for _, card in ipairs(cardBuffer) do
        deck:stage(card)
      end
      cardBuffer = {}
    else
      cardWaste.cards[#cardWaste.cards].draggable = true
    end
  end
  mousePressed = true
end

function love.mousereleased(x, y, button, istouch, releases)
  if button == 1 and draggableCard then
    draggableCard:stopDrag(x, y)
    draggableCard = nil
  end
  mousePressed = false
end
