--notes
--Linha azul é até onde o player se movimento
--GameState


local anim = require("lib/anim8")
local animation ,images

function love.load()


    -- O mouse não aparece dentro da janela
    love.mouse.setVisible(false)
    -- Pontuação de inimigos mortos
    score = 0
    -- Array para pegar outros elemetos do personagem/player
    player =  {}    
    
    --Vida do player
    player.hp = 10
    -- Velociadade do player
    player.Vel = 160    
    --Intervalo de ataque do player
    podeBater = true
    player.cdMax = 1
    -- DECLARANDO A POSIÇÃO DO PLAYER NA TELA JOGO
    player.x = 150
    player.y = 400 
    -- DECLANRANDO O TAMANHO DO PERSONAGEM/PLAYER NA TELA
    player.w = 96
    player.h = 186
    -- Instacia que manipula o lado das a sprites ser utilisado
    player.direction = "stop"
    -- Variaveis para guardar a ultima direção que o player esteve
    dRight = true   
    dLeft = false
    --Um Array de inimigos
    enemys = {}
    SpawnList()
    -- enemys.direction = "right"
    -- Array(lista) para as imagens
    images = {}
    animation= {}
    -- Um arraylist para fonte de letra
    fonts = {}
    -- Uma fonte de letra
    fonts.large = love.graphics.newFont("assets/fonts/Gamer.ttf", 36)
    -- Fundo/Cenario
    images.background = love.graphics.newImage("assets/images/ground.png")
    -- Sprites do player
    images.player_weak_attack =  love.graphics.newImage("assets/images/protagonista_atacando.png")
    images.player_stop =  love.graphics.newImage("assets/images/protagonista_parado.png")
    images.player_walk =  love.graphics.newImage("assets/images/protagonista_andando.png")
    --Sprites dos inimigos
    -- images.enemy_walk =  love.graphics.newImage("assets/images/capanga_andando_verde.png")

    
    -- Animação com o uso da biblioteca "anim8"
    -- Player
    local weak_attack = anim.newGrid(162, 204, images.player_weak_attack:getWidth(), images.player_weak_attack:getHeight())
    animation.weakAttack = anim.newAnimation( weak_attack('1-6', 1), 0.12)
    local pstop = anim.newGrid(96, 186, images.player_stop:getWidth(), images.player_stop:getHeight())
    animation.Stop = anim.newAnimation( pstop('1-2', 1), 0.25)
    local pwalk = anim.newGrid(94, 186, images.player_walk:getWidth(), images.player_walk:getHeight())
    animation.Walk = anim.newAnimation( pwalk('1-6', 1), 0.15)
    -- -- Inimigos
    -- local ewalk = anim.newGrid(96, 168, images.enemy_walk:getWidth(), images.enemy_walk:getHeight())
    -- animation.eWalk = anim.newAnimation( ewalk('1-7', 1), 0.15)
    
end

    
function love.update(dt)
    --Temporizador de ataque do player 
    player.cdMax = player.cdMax - dt
    if player.cdMax < 0 then
        podeBater = true
        player.cdMax = player.cdMax + 1 
    end
    if love.keyboard.isDown("q") then --Para Testes
        -- Chama o metodo de outro lugar
        enemySpawn(2, 300,400)
    end
    for i,v in ipairs(enemys) do 
        
        v.cdmax = v.cdmax - dt
        if v.cdmax < 0 then
            v.atacando = true
            v.cdmax = v.cdmax + 1
        end
        
    end
    
    -- Chama o metodo de outro lugar
    fakeAI(dt)
    -- Chama o metodo de outro lugar
    movements(dt)
end
    

function love.draw()
    -- Fundo/Cenario
    for x=0, love.graphics.getWidth(), images.background:getWidth() do
        for y=0, love.graphics.getHeight(), images.background:getHeight() do
            love.graphics.draw(images.background, x, y)
        end
    end
    
    
    -- Inimigos
    for i,v in ipairs(enemys) do 
        love.graphics.setColor(1,0,0)
        love.graphics.rectangle("fill",v.x,v.y,v.w,v.h)
        love.graphics.setColor(1,1,1)
    end
    --  Chama o metodo de outro lugar
    spritesAnimation()

    love.graphics.setFont(fonts.large)
    --mostra a pontuação do jogo
    love.graphics.print("SCORE: " .. score, 10, 10)
    love.graphics.print("HP= " .. player.hp,10,40)
    --Usar só para ver o range dos ataques
   -- love.graphics.setColor(0,1,1)
    --if dLeft == true then
     --love.graphics.rectangle("line",player.x-160,player.y,player.w-16,player.h-60)
     --end
   --if dRight == true then
     --love.graphics.rectangle("line",player.x,player.y,player.w-16,player.h-60)
     --end
     --love.graphics.setColor(1,1,1)
end

--persegue o player :D
function fakeAI(dt)
    for i,v in ipairs(enemys) do
        distxt = player.x - v.x
        if distxt >= -800 and distxt <= 800 then
            if player.x > v.x and playerColid(player.x-96,player.y,player.w,player.h,v.x,v.y,v.h,v.w) == false and v.vivo == true then 
                distX = (player.x - 96) - (v.x-60)
                distY = player.y - (v.y)
                dist = math.sqrt(distX*distX+distY*distY)
                velX = distX/dist*v.vel
                velY = distY/dist*v.vel
                v.x = v.x + velX*dt
                v.y = v.y + velY*dt
            end 
            if player.x < v.x and playerColid(player.x-96,player.y,player.w,player.h,v.x,v.y,v.h,v.w) == false and v.vivo == true then 
                distX = (player.x - 96) - (v.x + 20)
                distY = player.y - (v.y)
                dist = math.sqrt(distX*distX+distY*distY)
                velX = distX/dist*v.vel
                velY = distY/dist*v.vel
                v.x = v.x + velX*dt
                v.y = v.y + velY*dt
            end
            if v.vida <= 0 then
                --v.vivo = false
                table.remove(enemys,i)
                score = score + 10
            end

            --Ataque dos inimigos
            if playerColid(player.x-96,player.y,player.w,player.h,v.x,v.y,v.h,v.w) and v.atacando == true then
                v.atacando = false
                player.hp = player.hp - v.dano
            end

        end
    end
end

    --Spawn
function enemySpawn(enemyType , enemyX , enemyY)
    --enemy type 1: Capangas Verdes, 2:Capanga Amarelos, 3: Capangas Vermelhos, 4: Boss
   -- if(player.x < spawnX)then
        if(enemyType == 1) then
            local enemy = {}
            enemy.atacando = true
            enemy.type = 1
            enemy.cdmax = 1
            enemy.dano = 1
            enemy.vivo = true
            enemy.vida = 3
            enemy.x = enemyX
            enemy.y = enemyY
            enemy.w = 50
            enemy.h = 100
            enemy.vel = 80
            table.insert(enemys,enemy)
        end
        if(enemyType == 2) then
            local enemy = {}
            enemy.atacando = true
            enemy.type = 2
            enemy.cdmax = 1
            enemy.dano = 1
            enemy.vivo = true
            enemy.vida = 6
            enemy.x = enemyX
            enemy.y = enemyY
            enemy.w = 50
            enemy.h = 100
            enemy.vel = 80
            table.insert(enemys,enemy)
            end
        if(enemyType == 3) then
            local enemy = {}
            enemy.atacando = true
            enemy.type = 3
            enemy.cdmax = 1
            enemy.dano = 1
            enemy.vivo = true
            enemy.vida = 9
            enemy.x = enemyX
            enemy.y = enemyY
            enemy.w = 50
            enemy.h = 100
            enemy.vel = 90
            table.insert(enemys,enemy)
        end 
        if(enemyType == 4) then
            local enemy = {}
            enemy.atacando = true
            enemy.type = 4
            enemy.cdmax = 1
            enemy.dano = 1
            enemy.vivo = true
            enemy.vida = 60
            enemy.x = enemyX
            enemy.y = enemyY
            enemy.w = 50
            enemy.h = 100
            enemy.vel = 80
            table.insert(enemys,enemy)
        end 
    --end
end

-- CONTROLES
function movements(dt)
    -- Se o player precionar seta para direita o personagem anda para a direita e ativa a animação
    if love.keyboard.isDown("right") then
        player.x = player.x + 150 * dt
        player.direction = "right"
        animation.Walk:update(dt)
        -- Se o player precionar seta para direita junto com a seta para cima
        -- o personagem anda pela direita para cima e ativa a animação
        -- tambem impede do personagem atravessar parte do cenario
        if love.keyboard.isDown("up") and player.y + player.h - 25 > 370 then 
            player.y = player.y - 150 * dt        
            player.direction = "right"
            animation.Walk:update(dt)
        end    
        -- Se o player precionar seta para direita junto com a seta para baixo
        -- o personagem anda pela direita para baixo e ativa a animação
        if love.keyboard.isDown("down") then
            player.y = player.y + 150 * dt        
            player.direction = "right"
            animation.Walk:update(dt)
        end  
        

    -- Se o player precionar seta para esquerda o personagem anda para a esquerda e ativa a animação
    elseif love.keyboard.isDown("left") then
        player.x = player.x - 150 * dt
        player.direction = "left"
        animation.Walk:update(dt)
        
        -- Se o player precionar seta para esquerda junto com a seta para cima
        -- o personagem anda pela direita para cima e ativa a animação
        -- tambem impede do personagem atravessar parte do cenario
        if love.keyboard.isDown("up") and player.y + player.h - 25 > 370 then 
            player.y = player.y - 150 * dt
            player.direction = "left"
            animation.Walk:update(dt)
        end
        -- Se o player precionar seta para direita junto com a seta para baixo
        -- o personagem anda pela direita para baixo e ativa a animação
        if love.keyboard.isDown("down") then
            player.y = player.y + 150 * dt        
            player.direction = "left"
            animation.Walk:update(dt)
        end
    -- Se o player precionar seta para cima o personagem anda para a cima e ativa a animação 
    -- e junto pega a variavel booleana para pega a ultima direção para o qual o personagem foi designado
    elseif love.keyboard.isDown("up") and player.y + player.h - 25 > 370 then 
        player.y = player.y - 150 * dt
        if dRight == true then
            player.direction = "right"
        else
            player.direction = "left"
        end
        animation.Walk:update(dt)
        
    -- Se o player precionar seta para baixo o personagem anda para a baixo e ativa a animação 
    -- e junto pega a variavel booleana para pega a ultima direção para o qual o personagem foi designado
    elseif love.keyboard.isDown("down") then  
        player.y = player.y + 150 * dt
        if dLeft == true then
            player.direction = "left"
        else
            player.direction = "right"
        end
        animation.Walk:update(dt)
    else
        player.direction = "stop"
        animation.Stop:update(dt)
    end

    --Ataque do player
    -- Apertando "e" ele usa o ataque fraco
    -- Caso um inimigo esteja proximo ele executa o metodo para atacar e remover o inimigo
        if love.keyboard.isDown("e") and podeBater == true then
            if dRight == true then
                player.direction = "weakAttackRight"
            else
                player.direction = "weakAttackLeft"
            end
            animation.weakAttack:update(dt)
            weakAttack()
        end
        
    
    -- Metodo de ataque do player
    function weakAttack()
        for i,v in ipairs(enemys) do
            if love.keyboard.isDown("e") and dRight == true and podeBater == true then
                if playerColid(player.x,player.y,player.w-16,player.h-60,v.x,v.y,v.h,v.w) then
                    v.vida = v.vida - 3  
                end
                podeBater = false
            end   
            if love.keyboard.isDown("e") and dLeft == true and podeBater == true then  
                if playerColid(player.x-160,player.y,player.w-16,player.h-60,v.x,v.y,v.h,v.w) then
                    v.vida = v.vida - 3                  
                end
                podeBater = false
            end
        end
    end

end 

-- Animação das sprites onde tambem manipula a direção em que o personagem esta.
function spritesAnimation()
    -- Controle de sprites do Player
    if player.direction == "right" then
        -- Sprite virada para direita
        animation.Walk:draw(images.player_walk, player.x, player.y, 0, 1, 1, 90, 0)
        -- Sobrepoie a variavel e guarda para quando for nescessario 
        dRight = true
        dLeft = false
    elseif player.direction == "left" then
        -- Sprite virada para esquerda
        animation.Walk:draw(images.player_walk, player.x, player.y, 0, -1, 1, 0, 0)
        -- Sobrepoie a variavel e guarda para quando for nescessario 
        dRight = false
        dLeft = true
    -- Caso o player fique parado, ira acionar essa animação
    elseif  player.direction == "stop" and dRight == true then
        -- Sprite virada para direita
        animation.Stop:draw(images.player_stop, player.x, player.y, 0, 1, 1, 90, 0)
    elseif player.direction == "stop" and dLeft == true then
        -- Sprite virada para esquerda
        animation.Stop:draw(images.player_stop, player.x, player.y, 0, -1, 1, 0, 0)
    -- Caso o player ataque, ira acionar essa animação
    elseif  player.direction == "weakAttackRight" and dRight == true then
        -- Sprite virada para direita
        animation.weakAttack:draw(images.player_weak_attack, player.x, player.y, 0, 1, 1, 90, 18)
    elseif player.direction == "weakAttackLeft" and dLeft == true then
        -- Sprite virada para esquerda
        animation.weakAttack:draw(images.player_weak_attack, player.x, player.y, 0, -1, 1, 0, 18)
    end
    -- Controle de sprites do Player
    -- if enemy.direction == "right" then
    --     animation.eWalk:draw(images.enemy_walk, enemy.x, enemy.y, 0, 1, 1, 90, 0)
    -- elseif enemy.direction == "left" then
    --     animation.eWalk:draw(images.enemy_walk, enemy.x, enemy.y, 0, -1, 1, 0, 0)
    -- end
end

function playerColid(x1, y1, w1, h1, x2, y2, h2, w2)
    return  x1 < x2 + w2 and
            x1 + w1 > x2 and 
            y1 < y2 + h2 and
            y1 + h1 > y2
end
    
function SpawnList()
enemySpawn(2, 1200,400)    
    

end
    
    