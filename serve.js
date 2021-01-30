const {createServer:server}=require('http')
const url=require('url')
const fs=require('fs')
const wavPath='./bb.mp4'
var stats = fs.statSync(wavPath);
server((req,res)=>{
	let pathname=url.parse(req.url).pathname
	if(pathname==='/bb.mp4'){
		let range = req.headers['range']
		if(range){
			let ranges = range.replace('bytes=','')
			let rangesplit = ranges.split('-')
			let start=parseInt(rangesplit[0])
			let end=parseInt(rangesplit[1]) || stats.size-1
			let length = end - start
			res.setHeader('Content-Range',`bytes ${start}-${end}/${stats.size}`)
			res.setHeader('Content-Type','audio/wav')
			res.setHeader('Content-Length',`${length + 1}`)
			res.writeHead(206)
		  fs.createReadStream(wavPath,{
					start:start,
					end:end
				}).pipe(res)
		}else{
			res.writeHead(200,{'Content-Type':'video/mp4'})
			fs.createReadStream(wavPath).pipe(res)
		}
		return
	}
	res.end()
}).listen(8080,()=>{
	console.log(`server listen on 8080`)
})