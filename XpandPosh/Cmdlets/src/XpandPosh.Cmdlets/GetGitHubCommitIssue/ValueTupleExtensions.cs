using System;
using System.Linq;
using DynamicExpressions.Linq;
using Fasterflect;

namespace XpandPosh.Cmdlets.GetGitHubCommitIssue{
    public static class ValueTupleExtensions{
        public static object ToClass<T1, T2>(this (T1, T2) tuple){
            var tuples = new (Type type, object value)[]{
                (typeof(T1), tuple.Item1), 
                (typeof(T2), tuple.Item2)
            };
            return tuples.ToClass();
        }

        public static object ToClass<T1, T2, T3,T4>(this (T1, T2, T3,T4) tuple){
            var tuples = new (Type type, object value)[]{
                (typeof(T1), tuple.Item1), 
                (typeof(T2), tuple.Item2),
                (typeof(T3), tuple.Item3),
                (typeof(T4), tuple.Item4)
            };
            return tuples.ToClass();
        }

        public static object ToClass<T1, T2,T3>(this (T1, T2,T3) tuple){
            var tuples = new (Type type, object value)[]{
                (typeof(T1), tuple.Item1), 
                (typeof(T2), tuple.Item2),
                (typeof(T3), tuple.Item3)
            };
            return tuples.ToClass();
        }

        private static object ToClass(this (Type type, object value)[] tuples){
            var valueTuples = tuples
                .GroupBy(_ => _.type)
                .SelectMany(_ => _.Select((tuple, index) => (tuple.type,tuple.value,name:GetName(tuple.type,tuples, index))))
                .ToArray();
            var type = DynamicExpression.CreateClass(valueTuples.Select(_ => new DynamicProperty(_.name, _.type)));
            var instance = type.CreateInstance();
            foreach (var _ in valueTuples) instance.SetPropertyValue(_.name, _.value);

            return instance;
        }

        private static string GetName(Type type, (Type type, object value)[] tuples,int index){
            var name = type.IsArray ? $"{type.GetElementType()?.Name}s" : type.Name;
            var types = tuples.Where(tuple => tuple.type==type).Select(tuple => tuple.type).ToArray();
            if (types.Length > 1){
                name += index+1;
            }
            return name;
        }
    }
}