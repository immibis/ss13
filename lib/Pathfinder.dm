// From BYOND hub: Theodis.Pathfinder
// Modified to hard-code the callback functions

/*

Updates
(May 17th 2007) Version 10
Added new functionality to the dijkstra algorithm to allow for simultanious
searches from a single starting point.  This is much faster than making several
calls as no work is repeated in the search.  Depending on how you handled your
finished proc previously this may break old code.  Previously finished only
expected a bool and now it expects specific values to know if it should just add
a list or add a list and continue.  For the old behaviour you should just return
P_DIJKSTRA_FINISHED(which is equal to 1).  Since it's equal to 1 I'm hoping that
it won't break most code.  However you should still update to the constants to
ensure your code won't break in future versions if I need to change these values
or possibly add more.  There is also a compatibility mode which is by default
on.  If only one list is returned and compatibility mode is on the return value
will be the same as previous versions.  If it's off then it'll simple return a
list of one path which should be simpler if you're expecting the new
functionality and are handling a nested list.

(May 15th 2007) Version 9
Adjusted when testing if a node is the finish point or not.  Previously if the
ending node was accessable from a node it'd jump to it ignoring the cost.  For
most cases this is ok.  However if the costs for entering vary depending on
direction this could produce paths which aren't the shortest according to the
weighted distances.  This is now fixed in all 3 algorithms.  Thanks goes to
Shadowdancer for finding the bug.

(April 22nd 2007) Version 8
Includes several new parameters to help improve the effeciency of searches
preformed by the library.

maxnodedepth - Defines the maximum number of nodes that can be traversed to get
to the destination node.  This will prevent any extra long paths from being
found but will prevent the algorithm from spending too long if you don't care to
find these paths anyway.  This parameter has been added for all the algorithms.

mintargetdist - Defines the minimum distance from the target for the path to be
complete.  Use this if you only need a path to be obtained that just needs to be
close to the target rather than get all the way there.  Note however that the
dist() proc passed in is used for calculating distance.  This parameter is only
for AStar().

minnodedist:src.minnodedist(dst) - A proc passed in which returns the minimum
possible nodes it could take to get from src to dst.  For example if this is
used on a turf map and the player can only possibly move one turf at a time with
diagonals then the minimum node distance from the target to the destination
would be the same as the value returned by the get_dist() proc.  However if you
need to compensate for a complex portal network or your movement isn't simple
then it may be unreasonable to try and solve for the minimum number of nodes it
would take to traverse from one to another.  If you can define this and set a
maxnodedepth then the preformance of the search should be drastically removed as
many impossible nodes will be quickly dropped off(along with all the nodes you'd
need to test if they had been tested.)

(April 14th 2007) Version 7
Fixes a runtime error generated from the case in which no path can be found.
null is properly returned now.

Version 6 fixes a small glitch with the Dijkstra procs starting with a weight of
1 on the first node rather than 0.

Version 5 adds in a parameter to DijkstraTurfInRange which allows you to select
whether or not you want it to return the interior datums or datums that met the
finishing criteria, or both.

Version 4 updates the demo to demonstrate adding movement costs to terrain as
well as adding a new function DijkstraTurfInRange.  This doesn't solve for a
path rather finds all turfs within a given range using a terminating function.
This was mainly added at Unknown Persons request for solving tiles which can be
moved to given the movement style and range of a unit however it can be used for
many other purposes such as finding all tiles accessable from a specific
location that you can get to without crossing a certain barrier.
Version 4 doesn't mess with any of the old functionality so it should be fully
backwards compatible with version 3.

Version 3 fixs the order of the path


Usage
This library contains implementations for two different pathfinding algorithms.
The A* algorithm is used to find the shortest path from one point to another
while the Dijkstra algorithm is used when the destination isn't known until you
get there or if you want to get several paths at once from the same starting
point.  For example if you want a mob to find a path to the nearest player but
don't know which is nearest you'd use the Dijkstra algorithm.  However if you
have a specific player you want to find a path to you'd use the A*
algorithm.

AStar(start,end,adjacent,dist,maxnodes,maxnodedepth,mintargetdist,minnodedist)
start - The starting location of the path
end - The destination location of the path
adjacent - The function which returns all adjacent nodes from the source node.
dist - The function which returns either the distance(along with any added
weights for taking the path) between two adjacent nodes or if the nodes aren't
adjacent the guessed distance between the two.
maxnodes - The maximum number of nodes that can be in the open list.  Pass in 0
for no limit.  Limiting the number of nodes may prevent certain paths from being
found but the the nodes removed are the least likely to lead to good paths so as
long as this value is sufficiently high this shouldn't be a problem.
maxnodedepth - Defines the maximum number of nodes that can be traversed to get
to the destination node.  This will prevent any extra long paths from being
found but will prevent the algorithm from spending too long if you don't care to
find these paths anyway.
mintargetdist - Defines the minimum distance from the target for the path to be
complete.  Use this if you only need a path to be obtained that just needs to be
close to the target rather than get all the way there.  Note however that the
dist() proc passed in is used for calculating distance.
minnodedist:src.minnodedist(dst) - A proc passed in which returns the minimum
possible nodes it could take to get from src to dst.  For example if this is
used on a turf map and the player can only possibly move one turf at a time with
diagonals then the minimum node distance from the target to the destination
would be the same as the value returned by the get_dist() proc.  However if you
need to compensate for a complex portal network or your movement isn't simple
then it may be unreasonable to try and solve for the minimum number of nodes it
would take to traverse from one to another.  If you can define this and set a
maxnodedepth then the preformance of the search should be drastically removed as
many impossible nodes will be quickly dropped off(along with all the nodes you'd
need to test if they had been tested.)

Dijkstra(start,adjacent,dist,finished,maxnodedepth,compatibility=1)
start - The starting location of the path
adjacent - The function which returns all adjacent nodes
from the source node.
dist - The function which returns either the distance(along with any added
weights for taking the path) between two adjacent nodes or if the nodes aren't
adjacent the guessed distance between the two.
finished - The function which returns a flag which is either
P_DIJKSTRA_NOT_FOUND, P_DIJKSTRA_FINISHED, or P_DIJKSTRA_ADD_PATH.
P_DIJKSTRA_NOT_FOUND indicates this node is not a finishing point.
P_DIJKSTRA_FINISHED indicates this node is a finishing point and that no more
paths need to be found.
P_DIJKSTRA_ADD_PATH indicates this node is a finishing point and adds the path
to this node to the paths list.  However rather than terminating the search it
continues to try and find more paths.
maxnodedepth - Defines the maximum number of nodes that can be traversed to get
to the destination node.  This will prevent any extra long paths from being
found but will prevent the algorithm from spending too long if you don't care to
find these paths anyway.
compatibility - A boolean turning on or off compatibility mode.  If
compatibility mode is on and only one path is generated then it'll return that
path rater than returning a list of paths containing one path.  If there are
more than 1 paths however then a list of paths will be returned regardless of
this setting

DijkstraTurfInRange(start,adjacent,dist,finished,include,maxnodedepth)
This functions like the Dijkstra proc except that rather than returning a path
it returns all nodes up to and including the finishing one.  And it keeps
running until all paths up to a finishing point are tested so ensure you have
some kind of distance constraint or are searching in an area tightly bound by
finishing restrictions.

include - A parameter which determines which datums to return
	Values
	P_INCLUDE_INTERIOR - All datums in the area except the ones meeting the
		finishing conditions.
	P_INCLUDE_FINISHED - All datums meeting the finishing conditions.
	If you or the parameters you get everything which is the default parameter
	if nothing is passed for it.

*/


var/const/P_DIJKSTRA_NOT_FOUND = 0
var/const/P_DIJKSTRA_FINISHED = 1
var/const/P_DIJKSTRA_ADD_PATH = 2
var/const/P_INCLUDE_INTERIOR = 1
var/const/P_INCLUDE_FINISHED = 2

PathNode
	var
		datum/source
		PathNode/prevNode
		f
		g
		h
		nt		// Nodes traversed
	New(s,p,pg,ph,pnt)
		source = s
		prevNode = p
		g = pg
		h = ph
		f = g + h
		source.bestF = f
		nt = pnt

datum
	var
		bestF

proc
	PathDistance(turf/A, turf/B)
		return abs(A.x-B.x) + abs(A.y-B.y)
	PathAdjacent(turf/A)
		var/list/L = new
		dirloop:
			for(var/dir in list(NORTH, SOUTH, EAST, WEST))
				var/turf/B = get_step(A, dir)
				if(!B)
					continue
				if(B.density)
					continue
				for(var/atom/movable/AM in B)
					if(istype(AM, /obj/machinery/door))
						//var/obj/machinery/door/D = AM
						// todo: check req_access
						continue
					else if(AM.density)
						continue dirloop
				L += B
		return L

proc
	PathWeightCompare(PathNode/a, PathNode/b)
		return a.f - b.f

	AStar(turf/start,turf/end,maxnodes,mintargetdist)
		var/PriorityQueue/open = new /PriorityQueue(/proc/PathWeightCompare)
		var/closed[] = new()
		var/path[]

		if(start.z != end.z)
			return null

		open.Enqueue(new /PathNode(start,null,0,PathDistance(start,end)))

		while(!open.IsEmpty() && !path)
		{
			var/PathNode/cur = open.Dequeue()
			closed.Add(cur.source)

			var/closeenough
			if(mintargetdist)
				closeenough = PathDistance(cur.source, end) <= mintargetdist

			if(cur.source == end || closeenough) //Found the path
				path = new()
				path.Add(cur.source)
				while(cur.prevNode)
					cur = cur.prevNode
					path.Add(cur.source)
				break

			//if(PathDistance(cur.source, end) + cur.nt >= maxnodedepth)
				//continue

			var/L[] = PathAdjacent(cur.source)

			for(var/datum/d in L)
				//Get the accumulated weight up to this point
				var/ng = cur.g + PathDistance(cur.source, d)
				if(d.bestF)
					if(ng + PathDistance(d, end) < d.bestF)
						for(var/i = 1; i <= open.L.len; i++)
							var/PathNode/n = open.L[i]
							if(n.source == d)
								open.Remove(i)
								break
					else
						continue

				open.Enqueue(new /PathNode(d,cur,ng,PathDistance(d, end),cur.nt+1))
				if(maxnodes && open.L.len > maxnodes)
					open.L.Cut(open.L.len)
		}

		var/PathNode/temp
		while(!open.IsEmpty())
			temp = open.Dequeue()
			temp.source.bestF = 0
		while(closed.len)
			temp = closed[closed.len]
			temp.bestF = 0
			closed.Cut(closed.len)

		if(path)
			for(var/i = 1; i <= path.len/2; i++)
				path.Swap(i,path.len-i+1)

		return path

	Dijkstra(start,adjacent,dist,finished,maxnodedepth,compatibility=1)
		var/PriorityQueue/open = new /PriorityQueue(/proc/PathWeightCompare)
		var/closed[] = new()
		var/ret[] = new()
		var/path[]

		open.Enqueue(new /PathNode(start,null,0,0))

		while(!open.IsEmpty())
		{
			var/PathNode/cur = open.Dequeue()
			var/isDone
			closed.Add(cur.source)

			isDone = call(finished)(cur.source, cur.g)
			if(isDone)
				var/PathNode/tmpNode = cur
				path = new()
				path.Add(tmpNode.source)
				while(tmpNode.prevNode)
					tmpNode = tmpNode.prevNode
					path.Add(tmpNode.source)
				ret[++ret.len] = path
			if(isDone == P_DIJKSTRA_FINISHED)
				break

			var/L[] = call(cur.source,adjacent)()

			if(maxnodedepth && cur.nt >= maxnodedepth)
				continue

			for(var/datum/d in L)
				//Get the accumulated weight up to this point
				var/ng = cur.g + call(cur.source,dist)(d)

				if(d.bestF)
					if(ng < d.bestF)
						for(var/i = 1; i <= open.L.len; i++)
							var/PathNode/n = open.L[i]
							if(n.source == d)
								open.Remove(i)
								break
					else
						continue
				open.Enqueue(new /PathNode(d,cur,ng,0,cur.nt+1))
		}

		var/PathNode/temp
		while(!open.IsEmpty())
			temp = open.Dequeue()
			temp.source.bestF = 0
		while(closed.len)
			temp = closed[closed.len]
			temp.bestF = 0
			closed.Cut(closed.len)

		for(var/list/L in ret)
			for(var/i = 1; i <= L.len/2; i++)
				L.Swap(i,L.len-i+1)

		if(ret.len < 1)
			return null
		else if(ret.len == 1 && compatibility)
			return ret[1]
		return ret

	DijkstraTurfInRange(start,adjacent,dist,finished, include = P_INCLUDE_INTERIOR | P_INCLUDE_FINISHED,maxnodedepth)
		var/PriorityQueue/open = new /PriorityQueue(/proc/PathWeightCompare)
		var/closed[] = new()
		var/path[] = new()
		var/finishedL[] = new()

		open.Enqueue(new /PathNode(start,null,0,0))

		while(!open.IsEmpty())
		{
			var/PathNode/cur = open.Dequeue()
			closed.Add(cur.source)

			//Get the accumulated weight up to this point
			if(call(finished)(cur.source,cur.g)) //Found an end point
				finishedL += cur.source
				continue

			var/L[] = call(cur.source,adjacent)()

			if(maxnodedepth && cur.nt >= maxnodedepth)
				continue

			for(var/datum/d in L)
				var/ng = cur.g + call(cur.source,dist)(d)
				if(d.bestF)
					if(ng < d.bestF)
						for(var/i = 1; i <= open.L.len; i++)
							var/PathNode/n = open.L[i]
							if(n.source == d)
								open.Remove(i)
								break
					else
						continue
				open.Enqueue(new /PathNode(d,cur,ng,0,cur.nt+1))
		}

		var/PathNode/temp
		while(!open.IsEmpty())
			temp = open.Dequeue()
			temp.source.bestF = 0
		while(closed.len)
			temp = closed[closed.len]
			temp.bestF = 0
			path+=temp
			closed.Cut(closed.len)
		switch(include)
			if(P_INCLUDE_INTERIOR)
				return path
			if(P_INCLUDE_FINISHED)
				return finishedL
			if(P_INCLUDE_INTERIOR | P_INCLUDE_FINISHED)
				return path + finishedL
		return null