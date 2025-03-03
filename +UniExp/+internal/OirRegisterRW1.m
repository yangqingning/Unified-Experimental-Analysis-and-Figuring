classdef OirRegisterRW1<ParallelComputing.IBlockRWer
	properties(SetAccess=immutable)
		PieceSize
		NumPieces
		CollectData
		ProcessData
	end
	properties(SetAccess=immutable,GetAccess=private)
		OirPath
		BlockStarts
		BlockSizes uint16
		CacheFid
		NonTagChannel
		CacheDirectory
		WriteToCache
	end
	properties(Access=private)
		Reader Image5D.OirReader
		BlocksRead=0
	end
	methods
		function obj = OirRegisterRW1(OirPath,BlockSize,WriteToCache,CacheDirectory)
			obj.OirPath=OirPath;
			obj.Reader=Image5D.OirReader(OirPath);
			[Devices,Colors]=obj.Reader.DeviceColors;
			TagLogical=startsWith(Devices,'CD');
			obj.NumPieces=double(obj.Reader.SizeT);%20
			obj.ProcessData=TagLogical;
			NumBlocks=ceil(obj.NumPieces/BlockSize);
			BlockSplit=uint32(linspace(0,obj.NumPieces,NumBlocks+1));
			obj.BlockStarts=BlockSplit(1:end-1);
			obj.BlockSizes=BlockSplit(2:end)-obj.BlockStarts;
			obj.CollectData=struct(ChannelColors=Colors,DeviceNames=Devices,SeriesInterval=obj.Reader.SeriesInterval);
			if exist('CacheDirectory','var')
				[~,Filename]=fileparts(OirPath);
				obj.CacheFid=fopen(fullfile(CacheDirectory,Filename+".缓存"),"w");
				obj.NonTagChannel=find(~TagLogical);
				obj.CacheDirectory=CacheDirectory;
			else
				obj.CacheFid=0;
			end
			obj.WriteToCache=WriteToCache;
		end
		function Data=Read(obj,~,~)
			obj.BlocksRead=obj.BlocksRead+1;
			[Data,obj.Reader]=TryRead(obj.Reader,obj.OirPath,obj.BlockStarts(obj.BlocksRead),obj.BlockSizes(obj.BlocksRead));
			if obj.CacheFid
				fwrite(obj.CacheFid,Data(:,:,obj.NonTagChannel,:,:),'uint16');
			end
		end
		function Data=Write(obj,Data,~,~)
			if obj.WriteToCache
				CachePath=fullfile(obj.CacheDirectory,matlab.lang.internal.uuid+".缓存");
				Fid=fopen(CachePath,'w');
				fwrite(Fid,Data{3},"uint16");
				fclose(Fid);
				Data{3}=CachePath;
			end
		end
		function delete(obj)
			if obj.CacheFid
				fclose(obj.CacheFid);
			end
		end
	end
end