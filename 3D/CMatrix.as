#include "Vec3f.as"

shared class CMatrix
{
	private float[] matrix;

	CMatrix()
	{
		Matrix::MakeIdentity(matrix);
	}

	CMatrix(float[] matrix)
	{
		// Assume array is the correct length
		this.matrix = matrix;
	}

	CMatrix(CMatrix other)
	{
		opAssign(other);
	}

	void opAssign(const CMatrix &in other)
	{
		this.matrix = other.matrix;
	}

	bool opEquals(const CMatrix &in other)
	{
		return this.matrix == other.matrix;
	}

	CMatrix opMul(const CMatrix&in other)
	{
		float[] multMatrix;
		Matrix::Multiply(this.matrix, other.matrix, multMatrix);
		return CMatrix(multMatrix);
	}

	CMatrix@ opMulAssign(const CMatrix&in other)
	{
		Matrix::MultiplyImmediate(this.matrix, other.matrix);
		return this;
	}

	CMatrix@ SetScale(float x, float y, float z)
	{
		Matrix::SetScale(matrix, x, y, z);
		return this;
	}

	CMatrix@ SetScale(Vec3f scale)
	{
		return SetScale(scale.x, scale.y, scale.z);
	}

	CMatrix@ SetScale(float x)
	{
		return SetScale(x, x, x);
	}

	CMatrix@ SetTranslation(float x, float y, float z)
	{
		Matrix::SetTranslation(matrix, x, y, z);
		return this;
	}

	CMatrix@ SetTranslation(Vec3f translation)
	{
		return SetTranslation(translation.x, translation.y, translation.z);
	}

	CMatrix@ SetRotationDegrees(float x, float y, float z)
	{
		Matrix::SetRotationDegrees(matrix, x, y, z);
		return this;
	}

	CMatrix@ SetRotationDegrees(Vec3f rotation)
	{
		return SetRotationDegrees(rotation.x, rotation.y, rotation.z);
	}

	CMatrix@ SetRotationRadians(float x, float y, float z)
	{
		Matrix::SetRotationRadians(matrix, x, y, z);
		return this;
	}

	CMatrix@ SetRotationRadians(Vec3f rotation)
	{
		return SetRotationRadians(rotation.x, rotation.y, rotation.z);
	}

	CMatrix@ SetRotation(float x, float y, float z)
	{
		return SetRotationDegrees(x, y, z);
	}

	CMatrix@ SetRotation(Vec3f rotation)
	{
		return SetRotation(rotation.x, rotation.y, rotation.z);
	}

	CMatrix@ Identity()
	{
		Matrix::MakeIdentity(matrix);
		return this;
	}

	float[] toArray()
	{
		return matrix;
	}

	void Print(uint precision = 3)
	{
		for (uint j = 0; j < 4; j++)
		{
			string text = j == 0 ? "[[" : " [";

			for (uint i = 0; i < 4; i++)
			{
				if (i != 0)
				{
					text += ", ";
				}

				text += formatFloat(matrix[j * 4 + i], "", 0, precision);
			}

			text += j == 3 ? "]]" : "]";

			print(text);
		}
	}

	string toString(uint precision = 3)
	{
		string text;

		for (uint i = 0; i < matrix.size(); i++)
		{
			if (i != 0)
			{
				text += ", ";
			}

			if (i % 4 == 0)
			{
				text += "[";
			}

			text += formatFloat(matrix[i], "", 0, precision);

			if (i % 4 == 3)
			{
				text += "]";
			}
		}

		return "[" + text + "]";
	}
}
