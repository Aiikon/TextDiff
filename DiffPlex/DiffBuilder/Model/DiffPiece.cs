using System;
using System.Collections.Generic;

namespace DiffPlex.DiffBuilder.Model
{
    public enum ChangeType
    {
        Unchanged,
        Deleted,
        Inserted,
        Imaginary,
        Modified
    }

    public class DiffPiece : IEquatable<DiffPiece>
    {
        public ChangeType Type { get; set; }
        public int? Position { get; set; }
        public string Text { get; set; }
        public List<DiffPiece> SubPieces { get; set; }

        public DiffPiece(string text, ChangeType type, int? position = null)
        {
            SubPieces = new List<DiffPiece>();
            Text = text;
            Position = position;
            Type = type;
        }

        public DiffPiece()
            : this(null, ChangeType.Imaginary)
        {
        }

        public override bool Equals(object obj)
        {
            return Equals(obj as DiffPiece);
        }

        public bool Equals(DiffPiece other)
        {
            return other != null
                && Type == other.Type
                && EqualityComparer<int?>.Default.Equals(Position, other.Position)
                && Text == other.Text
                && SubPiecesEqual(other);
        }

        public override int GetHashCode()
        {
            var hashCode = 1688038063;
            int? subPiecesCount = null;
            if (SubPieces != null)
                subPiecesCount = SubPieces.Count;
            hashCode = hashCode * -1521134295 + Type.GetHashCode();
            hashCode = hashCode * -1521134295 + EqualityComparer<int?>.Default.GetHashCode(Position);
            hashCode = hashCode * -1521134295 + EqualityComparer<string>.Default.GetHashCode(Text);
            hashCode = hashCode * -1521134295 + EqualityComparer<int?>.Default.GetHashCode(subPiecesCount);
            return hashCode;
        }

        private bool SubPiecesEqual(DiffPiece other)
        {
            if (SubPieces == null)
                return other.SubPieces == null;
            else if (other.SubPieces == null)
                return false;

            if (SubPieces.Count != other.SubPieces.Count)
                return false;

            for (int i = 0; i < SubPieces.Count; i++)
            {
                if (!Equals(SubPieces[i], other.SubPieces[i]))
                    return false;
            }

            return true;
        }
    }
}