function aStarSearch(graph, start, end) {
    let openSet = [start];
    let cameFrom = {};
    let gScore = { [start]: 0 };
    let fScore = { [start]: heuristic(start, end) };
  
    while (openSet.length > 0) {
      let current = openSet.reduce((a, b) => (fScore[a] < fScore[b] ? a : b));
      if (current === end) return reconstructPath(cameFrom, current);
  
      openSet = openSet.filter(node => node !== current);
      graph[current].neighbors.forEach(neighbor => {
        let tentative_gScore = gScore[current] + graph[current].cost[neighbor];
        if (tentative_gScore < (gScore[neighbor] || Infinity)) {
          cameFrom[neighbor] = current;
          gScore[neighbor] = tentative_gScore;
          fScore[neighbor] = gScore[neighbor] + heuristic(neighbor, end);
          if (!openSet.includes(neighbor)) openSet.push(neighbor);
        }
      });
    }
    return null;
  }
  