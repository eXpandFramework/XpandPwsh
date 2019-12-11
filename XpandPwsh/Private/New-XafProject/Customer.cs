using DevExpress.Persistent.Base;
using DevExpress.Persistent.BaseImpl;
using DevExpress.Xpo;

namespace $SolutionName{
    [DefaultClassOptions]
    public class Customer : Person{
        public Customer(Session session) : base(session){
        }
    }
}