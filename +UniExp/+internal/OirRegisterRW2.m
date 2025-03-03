classdef OirRegisterRW2<ParallelComputing.IBlockRWer
	properties(SetAccess=immutable)
		PieceSize
		NumPieces
		CollectData
		ProcessData={}
	end
	properties(SetAccess=immutable,GetAccess=private)
		Writer Image5D.OmeTiffRWer
		OirPath
		Translation
		NontagChannels
		CacheFid
		SizeX
		SizeY
		SizeC
		SizeZ
		MeanWriter Image5D.OmeTiffRWer
	end
	properties(Access=private)
		Reader Image5D.OirReader
		Sum
	end
	methods
		function obj = OirRegisterRW2(OirPath,Translation,OutputDirectory,CacheDirectory)
			import Image5D.*
			obj.OirPath=OirPath;
			obj.Reader=OirReader(OirPath);
			[Device,Colors]=obj.Reader.DeviceColors;
			obj.SizeX=obj.Reader.SizeX;
			obj.SizeY=obj.Reader.SizeY;
			obj.SizeC=obj.Reader.SizeC;
			obj.SizeZ=obj.Reader.SizeZ;
			obj.NumPieces=obj.Reader.SizeT;
			obj.PieceSize=2*prod([uint32(obj.SizeX),obj.SizeY,obj.SizeC,obj.SizeZ]);
			obj.NontagChannels=find(~startsWith(Device,'CD'));
			[~,Filename]=fileparts(OirPath);
			Colors=ChannelColor.FromOirColors(Colors(:,obj.NontagChannels));
			obj.Writer=OmeTiffRWer.Create(fullfile(OutputDirectory,Filename+".tif"),PixelType.UINT16,obj.SizeX,obj.SizeY,Colors,obj.SizeZ,obj.NumPieces,DimensionOrder.XYCZT);
			obj.NontagChannels=obj.NontagChannels-1;
			obj.Translation=Translation;
			if exist('CacheDirectory','var')
				[~,Filename]=fileparts(OirPath);
				obj.CacheFid=fopen(fullfile(CacheDirectory,Filename+".缓存"));
				obj.SizeC=numel(obj.NontagChannels);
			else
				obj.CacheFid=0;
			end
			obj.MeanWriter=OmeTiffRWer.Create(fullfile(OutputDirectory,Filename+".平均值.tif"),PixelType.UINT16,obj.SizeX,obj.SizeY,Colors,obj.SizeZ,1,DimensionOrder.XYCZT);
		end
		function Data=Read(obj,Start,End)
			if obj.CacheFid
				Sizes=[obj.SizeX,obj.SizeY,obj.SizeC,obj.SizeZ,End-Start+1];
				Data={reshape(fread(obj.CacheFid,prod(Sizes),'uint16=>uint16'),Sizes),obj.Translation(Start:End,:,:)};
			else
				[Data,obj.Reader]=TryRead(obj.Reader,obj.OirPath,Start-1,End-Start+1,obj.NontagChannels);
				Data={Data,obj.Translation(Start:End,:,:)};
			end
		end
		function Data=Write(obj,Data,Start,End)
			obj.Writer.WritePixels(Data{1},Start-1,End-Start+1);
			if isempty(obj.Sum)
				obj.Sum=Data{2};
			else
				obj.Sum=obj.Sum+Data{2};
			end
			Data={};
			if End==obj.NumPieces
				obj.MeanWriter.WritePixels(uint16(obj.Sum/double(End)));
			end
		end
		function delete(obj)
			if obj.CacheFid
				fclose(obj.CacheFid);
			end
		end
	end
end