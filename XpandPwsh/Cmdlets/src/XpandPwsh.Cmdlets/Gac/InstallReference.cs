namespace XpandPwsh.Cmdlets.Gac{
    public class InstallReference{
        public InstallReference(InstallReferenceType type, string identifier, string description){
            Type = type;
            Identifier = identifier;
            Description = description;
        }

        public InstallReferenceType Type{ get; }
        public string Identifier{ get; }
        public string Description{ get; }

        public bool CanBeUsed(){
            return Type == InstallReferenceType.Installer || Type == InstallReferenceType.FilePath ||
                   Type == InstallReferenceType.Opaque;
        }
    }
}