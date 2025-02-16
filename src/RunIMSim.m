function status = RunIMSim(IMSim_dir,EQSourceFile,SiteFile)

oldFolder = cd(IMSim_dir);
status = system(['IMSim ',EQSourceFile,' ',SiteFile]);
if status
    warning("地震动强度场模拟失败: %s - %s",EQSourceFile,SiteFile)
end
cd(oldFolder);

end