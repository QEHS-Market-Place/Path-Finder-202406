int mapSize = 150, cellSize = 5;
float wallValue = 0.0, d;
/* [PathFinding Algorithm]
 - Finding a path from one starting point to one end point using the concept of A*
 and Dijkstra's algorithm, and combining them into a simple pathfinder that is able to
 solve the users personally made maze. You can think of it as a rat in a maze the user
 can design.
 
 [https://thecodingtrain.com/challenges/51-a-pathfinding-algorithm]
 https://codingtrain.github.io/AStar/
 https://en.wikipedia.org/wiki/A*_search_algorithm
 https://aima.cs.berkeley.edu/
 
 It appears as through searching online and looking through examples, the search
 begins at a node, then moves to the node with the shortest distance to the end goal,
 if however it cannot travel any further, lets say it hits a corner or barrier, the
 algorithm will then return to a point at which multiple paths are available.
 */

ArrayList<Cell> cell;
float startCellX = 0, startCellY = 0;
float endCellX = mapSize, endCellY = mapSize;
boolean search = true, openpath = true, wallValchanging = true;

void settings () {
  size(mapSize*cellSize + 400, mapSize*cellSize);
  cell = new ArrayList<Cell>();

/* Creating the objects or *cells* for the map, each individual cell has to act different from the other */
  for (int j=mapSize-1; j>=0; j--) {
    for (int i=mapSize-1; i>=0; i--) {
      cell.add(new Cell(i, j, random(0, 1), cell.size()));
    }//for i
  }//for j
  cell.add(new Cell(mapSize-1, mapSize-1, 2, cell.size()));
  
}//settings

void setup () {
  colorMode(HSB);
  strokeWeight(0);
  searcherHVal = dist(searcherY/cellSize, searcherX/cellSize, endCellX, endCellY)*0.8 + dist(searcherX/cellSize, searcherY/cellSize, startCellX, startCellY)*0.5;
}

void draw() {
  background(0);
  /* displaying the map */
  for (int i=(mapSize*mapSize); i>0; i--) {
    Cell c = cell.get(i);
    c.mapGeneration();
  }//for i
  searcher();
  menu();
}//draw

void keyPressed () {
  if (key=='e') {search = false;} else {search = true;}
  if (key=='q') {wallValchanging = false;} else {wallValchanging = true;}
  
  if (keyCode==UP) {wallValue+=0.01;}
  if (keyCode==DOWN) {wallValue-=0.01;}
}//keyPressed


class Cell {
  float wallCheck, heauristicVal, rgb;
  float cellx, celly;
  float cellid, pathnum;
  boolean explored = false;

  Cell(int tempx, int tempy, float randomwall, int tempcellid) {
    this.cellx = tempx*cellSize;
    this.celly = tempy*cellSize;
    this.wallCheck = randomwall;
    heauristicVal = dist(cellx/cellSize, celly/cellSize, endCellX, endCellY)*0.8 + dist(cellx/cellSize, celly/cellSize, startCellX, startCellY)*0.5;
    this.cellid = tempcellid;
  }//Cell

  void mapGeneration() {
    if (wallCheck < wallValue) {
      fill(0);
    } else {
      fill(255);
    }// if wallcheck wallvalue

    if (wallCheck == 3 && search) {
      fill(color(150, 255, 150));
    }//if wallcheck 3
    if (wallCheck == 2) {
      fill(color(80, 255, 255));
    }//if wallcheck 2
    if (wallCheck == 3 && !search) {
      rgb++;
      fill(color(rgb, 255, 255));

      if (rgb > 255) {
        rgb = 0;
      }
    }
    if (explored) {
      fill(color(255, 255, 255));
      pathnum = 0;
    }//if explored

    square(cellx, celly, cellSize);
    if (dist(cellx, celly, searcherX, searcherY) <= 1) {
      wallCheck=3;
    }//if dist
  }//mapGeneration
}//class Cell


/*   :A_Star Pathfinding Formula:
 - Have the searcher know which cell it came from to where it is now
 * Add the preceeding cell to an array that holds the current path
 
 - The searcher needs to understand the movement cost for each cell, and chose the lowest cost possible
 * The lowest cost path will keep increasing in size the further we would go on, however it shouldnt be too big of an issue. Just a couple of if statements, maybe a loop.
 
 - If the current path is closed, or cannot be explored further, it must have a way to backtrack to another possible path
 * To backtrack, all you would need to do is restore the original values for that cell (cell colour, cell state) and remove it from the array.
 */// :A_Star Pathfinding Formula:

float movenum = 0;
float searcherX = startCellX, searcherY = startCellY;
float searcherHVal;
float time;
int generation;

void searcher() {
  /* The searcher itself */
  if (search) {
  time ++;
    for (int i = round(sq(mapSize)); i>0; i--) {
      Cell c = cell.get(i);
      if (c.wallCheck == 2 && dist(searcherX, searcherY, c.cellx, c.celly) <= cellSize || searcherHVal<=cellSize/10) {
        generation ++;
        time = 0;
        if (wallValchanging) wallValue += 0.01;
        startCellX = floor(searcherX/cellSize);
        startCellY = floor(searcherY/cellSize);
        endCellX = floor(random(1, mapSize-1));
        endCellY = floor(random(1, mapSize-1));
        d = -0.05;
        for (int j = (mapSize*mapSize); j>0; j--) {
          Cell e = cell.get(j);
          if (e.wallCheck >= 2 || e.explored) {
            e.wallCheck = 1;
            e.explored = false;
            e.pathnum = 0.1;
            movenum = 0;
            e.rgb = 0;
          }
          if (dist(e.cellx/cellSize, e.celly/cellSize, endCellX, endCellY) <= 0.1) {
            e.wallCheck = 2;
          }
          e.heauristicVal = dist(e.cellx/cellSize, e.celly/cellSize, endCellX, endCellY) + dist(e.cellx/cellSize, e.celly/cellSize, startCellX, startCellY)*0.5;
          searcherHVal = e.heauristicVal;
        }//for j
        //search = false;
      }//if c.wallCheck 2

      if (dist(c.cellx, c.celly, searcherX, searcherY) <= cellSize && c.wallCheck > wallValue && c.wallCheck !=3 && c.explored == false) {
        openpath = true;
      }//if dist && ...

      //Find the closest cell to know which cell its in. Get that cell id, get its heauristic value, place it in the path memory thing, cameFrom array, then move again.
      if (searcherHVal+d > c.heauristicVal && dist(c.cellx, c.celly, searcherX, searcherY) <= cellSize && c.wallCheck > wallValue && c.wallCheck != 3 && c.explored == false) {
        movenum++;
        c.pathnum = movenum;
        searcherX = c.cellx;
        searcherY = c.celly;
        c.wallCheck = 3;
        d = -0.05;
        i = -1;
        searcherHVal = c.heauristicVal;
      }//if searcherHVal c.heauristicVal && ...
    }//for i

    if (!openpath) {
      for (int i = round(sq(mapSize)); i>0; i--) {
        Cell e = cell.get(i);
        if (dist(e.cellx, e.celly, searcherX, searcherY) <= 1) {
          e.explored = true;
          movenum--;
        }//if dist

        if (e.pathnum == movenum) {
          searcherHVal = e.heauristicVal;
          searcherX = e.cellx;
          searcherY = e.celly;
          i = 0;
          d = -0.05;
        }//if e.pathnum movenum
      }//for i
    }//if !openpath
    d+=0.05;
    openpath = false;

    if (d > 10) {
      println("I got myself stuck!");
      if (wallValchanging) wallValue -= 0.01;
      generation ++;
      startCellX = floor(searcherX/cellSize);
        startCellY = floor(searcherY/cellSize);
        endCellX = floor(random(1, mapSize-1));
        endCellY = floor(random(1, mapSize-1));
        d = -0.05;
        for (int j = (mapSize*mapSize); j>0; j--) {
          Cell e = cell.get(j);
          if (e.wallCheck >= 2 || e.explored) {
            e.wallCheck = 1;
            e.explored = false;
            e.pathnum = 0.1;
            movenum = 0;
            e.rgb = 0;
          }
          if (dist(e.cellx/cellSize, e.celly/cellSize, endCellX, endCellY) <= 0.1) {
            e.wallCheck = 2;
          }
          e.heauristicVal = dist(e.cellx/cellSize, e.celly/cellSize, endCellX, endCellY) + dist(e.cellx/cellSize, e.celly/cellSize, startCellX, startCellY)*0.5;
          searcherHVal = e.heauristicVal;
        }//for j
    }//if d
  }//if search
  fill(0);
  circle(searcherX+cellSize/2, searcherY+cellSize/2, cellSize/2);
  noFill();
}//searcher


/* For extra information */

void menu() {
  translate(mapSize*cellSize,0);
  textAlign(CENTER);
  textSize(mapSize/cellSize);
  fill(255);
  text("Time: " + round(time/60), 200,(mapSize*cellSize)*1/3);
  text("Distance: " + round(dist(startCellX,startCellY,endCellX,endCellY)), 200,(mapSize*cellSize)*1/4);  
  text("Generation " + generation, 200,(mapSize*cellSize)*4/5);
  translate(-mapSize*cellSize,0);
}//menu
